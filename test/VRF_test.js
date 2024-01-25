const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token contract", function() {
    let factory;

    beforeEach(async () => {
        [owner, user] = await ethers.getSigners();

        const chainLinkFactory = await ethers.getContractFactory("OddEvenGame");
        factory = await chainLinkFactory.deploy(8768);
        await factory.waitForDeployment();

        // console.log("Factory deployed to:", factory.target);
    });
    
    describe("Deployment", async() => {
        it("Should set the right owner", async() => {
            console.log("Factory deployed to:", factory.target);

            console.log(await factory.get_subscriptionId());
            console.log("hi--hi")
            
            console.log(await factory.get_requestId());

            await factory.requestRandomWords();
            console.log(await factory.get_requestId());
            // await tx.wait();
            
        });
    });
})
