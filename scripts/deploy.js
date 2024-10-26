async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy the UniswapV3Factory contract
  const UniswapV3Factory = await ethers.getContractFactory("UniswapV3Factory");
  const factory = await UniswapV3Factory.deploy();

  // Print the transaction hash and contract address
  console.log("Transaction hash:", factory.deployTransaction.hash);
  console.log("UniswapV3Factory deployed to:", factory.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
