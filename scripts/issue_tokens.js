const { ethers } = require("hardhat");


async function a(callback) {
  const [acc1, acc2] = await ethers.getSigners();
  const TokenFarm = await ethers.getContractFactory("TokenFarm", acc1);
  const tokenfarm = await TokenFarm.deploy();
  await tokenfarm.deployed();

  const tx = await TokenFarm.issueTokens();
  await tx.wait();
  console.log("Tokens issued");
  callback();
}