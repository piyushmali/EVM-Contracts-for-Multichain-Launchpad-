const { ethers } = require("hardhat");

async function main() {
  // Get the deployer's account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Define the contract factory for EVMLaunchpad
  const EVMLaunchpad = await ethers.getContractFactory("EVMLaunchpad");

  // Deploy the contract (no constructor arguments)
  console.log("Deploying EVMLaunchpad...");
  const evmLaunchpad = await EVMLaunchpad.deploy();
  await evmLaunchpad.deployed();
  console.log("EVMLaunchpad deployed at:", evmLaunchpad.address);
}

// Execute the deployment script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
