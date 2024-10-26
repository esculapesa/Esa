require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.27",  // The latest version for your custom contracts
        settings: {
          optimizer: {
            enabled: true,
            runs: 200 // Enable optimizer to reduce contract size
          }
        }
      },
      {
        version: "0.8.12",  // The latest version for your custom contracts
        settings: {
          optimizer: {
            enabled: true,
            runs: 200 // Enable optimizer to reduce contract size
          }
        }
      },
      {
        version: "0.6.0",   // Add Solidity 0.6.0 for oracle.sol and other contracts
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  networks: {
    Esa: {  // Updated network name to 'Esa'
      url: "http://65.108.151.70:8545",  // Node IP with port 8545
      accounts: [`0x${process.env.PRIVATE_KEY}`] // Private key from .env file
    },
    // You can add more networks here if needed (e.g., mainnet, Goerli)
  }
};

