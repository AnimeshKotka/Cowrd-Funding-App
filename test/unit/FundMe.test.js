const { deployments, getNamedAccounts, ethers } = require("hardhat");
const { assert, expect } = require("chai");

describe("FundMe", () => {
  let fundMe, deployer;
  let mockV3Aggregator;
  beforeEach(async () => {
    deployer = (await getNamedAccounts()).deployer;
    await deployments.fixture(["all"]);
    fundMe = await ethers.getContract("FundMe", deployer);
    mockV3Aggregator = await ethers.getContract("MockV3Aggregator", deployer);
  });

  describe("constructor", () => {
    // it("sets the aggregator addresses correctly", async () => {
    //   const response = await fundMe.priceFeed;
    //   console.log(mockV3Aggregator);
    //   //   assert.equal(response, mockV3Aggregator.address || networkConfig[chainId].ethUsdPriceFeed);
    // });
  });

  describe("fund", () => {
    it("Fails if insufficient Eth", async () => {
      await expect(fundMe.fund()).to.be.revertedWith(
        "You need to spend more ETH!"
      );
    });
  });
});
