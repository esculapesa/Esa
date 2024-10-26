require("dotenv").config();
const { JsonRpcProvider, Wallet, parseEther } = require("ethers"); // Updated for ethers v6

async function main() {
  // Create a JSON-RPC provider using the Esa network RPC URL
  const provider = new JsonRpcProvider("http://65.108.151.70:8545");

  // Get the private key from the environment variable
  const privateKey = process.env.PRIVATE_KEY;

  if (!privateKey) {
    console.error("Private key not set in the environment");
    return;
  }

  // Create a wallet with the private key and provider
  const wallet = new Wallet(privateKey, provider);

  // Define the transaction
  const tx = {
    to: "0x0545F8823b77D3Ed39f24B2a7264CEcbe0569756", // Receiver address
    value: parseEther("0.01") // Sending 0.01 of the native currency (updated for v6)
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
