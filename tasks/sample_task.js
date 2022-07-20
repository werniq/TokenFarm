import { task } from 'hardhat/config';
import { TokenFarm } from '../contracts';

task("balance", "Displays balance")
    .addParam('account', 'Account address')
    .addOptionalParam('greeting', 'Greeting to print', 'Default greeting')
    .setAction(async (taskArgs, { ethers }) => {
        const account = taskArgs.account;
        const balance = ethers.provider.getBalance(account);
        console.log(balance.toString);
    });


task("stake", "Call stake func")
    .addParam("amount", "Amount to stake", 0, types.int)
    .addParam("token", "Stake from ETH to ...", types.address)
    .addOptionalParam("string", "String to print -_-")
    .setAction(async (taskArgs, { ethers, getNamedAccounts }) => {
        const account = (await getNamedAccounts())[taskArgs.account];

        const tokenfarm = await ethers.getContract('TokenFarm', account);
        const tx = await tokenfarm.addAllowedTokens(taskArgs.token);
        await tx.wait();
        const tx2 = await tokenfarm.stakeTokens(
            { value: taskArgs.amount,
              from: account,
              token: taskArgs.token
            }
            
            );
        await tx.wait();
        console.log(taskArgs.string);
    });

    
task("add", "Adds allowed token")
    .addParam("token", "Add allowed token")
    .setAction(async (taskArgs, { ethers, getNamedAccounts }) => {
        const account = (await getNamedAccounts());
        const tokenfarm = await ethers.getContract("TokenFarm", account);
        const tx = await tokenfarm.addAllowedTokens(taskARgs.token);
        await tx.wait();
    });


task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();
      
    for (const account of accounts) {
        console.log(account.address);
    }
});