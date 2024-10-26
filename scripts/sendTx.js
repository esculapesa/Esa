require("dotenv").config(); // Load environment variables
const ethers = require("ethers");

async function main() {
  // Connect to the RPC provider (Esa network)
  const provider = new ethers.providers.JsonRpcProvider("http://65.108.151.70:8545");

  // Get the private key from the environment variable
  const privateKey = process.env.PRIVATE_KEY;
  
  if (!privateKey) {
    console.error("Private key not set in the environment");
    return;
  }

  // Create a wallet with the private key
  const wallet = new ethers.Wallet(privateKey, provider);

  // Define the transaction
  const tx = {
    to: "0x0545F8823b77D3Ed39f24B2a7264CEcbe0569756", // Receiver address
    value: ethers.utils.parseEther("0.01") // Sending 0.01 of the native currency
  };

  try {
    // Send the transaction
    const transactionResponse = await wallet.sendTransaction(tx);
    console.log("Transaction sent! Hash:", transactionResponse.hash);

    // Wait for the transaction to be mined
    const receipt = await transactionResponse.wait();
    console.log("Transaction mined! Receipt:", receipt);
  } catch (error) {
    console.error("Error sending transaction:", error);
  }
}

main();

