// Load environment variables from .env
require("dotenv").config();
const hre = require("hardhat"); // Hardhat runtime environment (includes ethers)

async function main() {
  // Get the deployer account (first signer) from Hardhat
  const [deployer] = await hre.ethers.getSigners();

  // Log deployer address for verification
  console.log("Deploying contract with account:", deployer.address);

  try {
    // Get the contract factory for UniswapV3Factory
    const UniswapV3Factory = await hre.ethers.getContractFactory("UniswapV3Factory");

    // Deploy the contract
    const factory = await UniswapV3Factory.deploy();

    // Log the transaction hash
    console.log("Transaction hash:", factory.deployTransaction.hash);

    // Wait for the deployment to be mined
    const receipt = await factory.deployTransaction.wait();

    // Log the contract address after deployment
    console.log("UniswapV3Factory deployed at address:", factory.address);

  } catch (error) {
    console.error("Error during deployment:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Main execution error:", error);
    process.exit(1);
  });
