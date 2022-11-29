const hre = require("hardhat");

async function main() {
  const AutoWithdrawNFT = await hre.ethers.getContractFactory("AutoWithdraw");
  const AutoWithdraw = await AutoWithdrawNFT.deploy();

  await AutoWithdraw.deployed();

  console.log("AutoWithdraw deployed to:", AutoWithdraw.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
