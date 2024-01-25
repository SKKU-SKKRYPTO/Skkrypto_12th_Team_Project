const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const Factory = await ethers.getContractFactory("DiceGame");
    const contract = await Factory.deploy(8768);

    console.log("Contract deployed at:", contract.target);
}

main().then(() => process.exit(0)).catch((error) => {
    console.error("Error during deployment: ", error);
    process.exit(1);
});