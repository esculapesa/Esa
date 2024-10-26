require("dotenv").config(); // Load environment variables
const { ethers } = require("ethers");

async function main() {
  const provider = new ethers.JsonRpcProvider("http://65.108.151.70:8545");
  
  // Get the private key from the environment variable
  const privateKey = process.env.PRIVATE_KEY;
  
  if (!privateKey) {
    console.error("Private key not set in the environment");
    return;
  }

  // Create a wallet with the private key and provider
  const wallet = new ethers.Wallet(privateKey, provider);
  
  console.log("Deploying contracts with the account:", wallet.address);

  // Deploy the UniswapV3Factory contract
  try {
    // Get the contract factory (assumes contract is already compiled)
    const UniswapV3Factory = await ethers.getContractFactory("UniswapV3Factory", wallet);

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
