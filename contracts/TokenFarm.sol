// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract TokenFarm {
    address owner;
    string public name = "Dapp Token Farm";
    IERC20 public dappToken;


    // token address -> mapping of user address -> amounts
    mapping (address => mapping(address => uint256)) public stakingBalance;
    mapping (address => uint256) public uniqueTokensStaked;
    mapping (address => address) public tokenPriceFeedMapping;

    
    address[] allowedTokens;
    address[] public stakers;


    constructor(address _dappTokenAddress) public {
        dappToken = IERC20 (
            _dappTokenAddress
        );
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "You are not an owner");
        _;
    }


    function stakeTokens(uint256 _amount, address token) public payable {
        require(_amount > 0, "Amount cannot be lower than 0");
        if (tokenIsAllowed(token)) {
            updateUniqueTokenStake(msg.sender, token);
            IERC20 (token).transferFrom(msg.sender, address(this), _amount);
            stakingBalance[token][msg.sender] = stakingBalance[token][msg.sender] + _amount;
            if (uniqueTokensStaked[msg.sender] == 1) {
                stakers.push(msg.sender);
            }
        }
    }


    function unstakeTokens(address token) public {
        uint256 balance = stakingBalance[token][msg.sender];
        require(balance > 0, "Staking balance can not be 0");
        IERC20(token).transfer(msg.sender, balance);
        stakingBalance[token][msg.sender] = 0;
        uniqueTokensStaked[msg.sender] -= 1;
    }


    function setPriceFeedContract(address token, address priceFeed) public onlyOwner 
    {
        tokenPriceFeedMapping[token] = priceFeed;
    }


    function updateUniqueTokenStake(address user, address token) internal {
        if (stakingBalance[token][user] <= 0) {
            uniqueTokensStaked[user] += 1;
        }
    }

    


    function tokenIsAllowed(address token) public returns(bool) {
        for (uint256 i = 0; i <= allowedTokens.length; ++i) {
            if (allowedTokens[i] == token) {
                return true;
            } else {
                return false;
            }
        }
    }


    function addAllowedTokens(address token) public onlyOwner {
        allowedTokens.push(token);
    }


    function issueTokens() public onlyOwner {
        for (uint256 stakersIndex = 0; stakersIndex <= stakers.length; ++stakersIndex) {
            address recipient = stakers[stakersIndex];
            dappToken.transfer(recipient, getUserTotalValue(recipient));
        }
    }


    function getUserTotalValue(address user) public view returns(uint256) {
        uint256 totalValue = 0;
        if (uniqueTokensStaked[user] > 0) {
            for (
                uint256 allowedTokensIndex = 0;
                allowedTokensIndex < allowedTokens.length;
                allowedTokensIndex++
            ) {
            totalValue += getUserStakingBalanceEthValue(
                user,
                allowedTokens[allowedTokensIndex]
            );
            }
        }
    }


    function getUserStakingBalanceEthValue(address user, address token) public view returns(uint256) {
        if (uniqueTokensStaked[user] <= 0) {
            return 0;
        }
        return (stakingBalance[token][user] * getTokenETHPrice(token)) / (10**18);
    }


    function getTokenETHPrice(address token) public view returns(uint256) {
        address priceFeedAddress = tokenPriceFeedMapping[token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface (priceFeedAddress);
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint256(price);
        }
    
}