require("dotenv").config(); // Load environment variables
const { ethers } = require("hardhat"); // Import Hardhat's ethers outside the function

async function main() {
  // Get the deployer's wallet (signer) from Hardhat's ethers
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy the UniswapV3Factory contract
  try {
    // Get the contract factory, connected explicitly to the deployer
    const UniswapV3Factory = await ethers.getContractFactory("UniswapV3Factory", deployer);

    // Deploy the contract
    const factory = await UniswapV3Factory.deploy();

    console.log("Transaction hash:", factory.deployTransaction.hash);

    // Wait for deployment to be mined
    const receipt = await factory.deploymentTransaction().wait();
    console.log("UniswapV3Factory deployed to:", receipt.contractAddress);

  } catch (error) {
    console.error("Error deploying contract:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Main execution error:", error);
    process.exit(1);
  });
