const hre = require("hardhat");
const { ethers } = require("hardhat");


async function main(callback) {
  const [acc1, acc2] = await ethers.getSigners();
  
  console.log("Address deploying contract: ", acc1.address);
  
  const Dapptoken = await ethers.getContractFactory("DaPPToken", acc1);
  const dapptoken = await Dapptoken.deploy();
  await dapptoken.deployed();


  
  const contract = await ethers.getContractFactory("TokenFarm", acc1);
  const tokenfarm = await contract.deploy(dapptoken.address);
  await tokenfarm.deployed();
  console.log("Contract address: ", tokenfarm.address);  
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
