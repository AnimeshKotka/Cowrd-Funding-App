const { networkConfig, developmentChains } = require("../helper-hardhat");
const { network } = require("hardhat");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  let ethUsdPriceFeedAddress;
  if (developmentChains.includes(network.name)) {
    const ehtUSDAggrigator = get("MockV3Aggregator");
    ethUsdPriceFeedAddress =
      ehtUSDAggrigator.address || networkConfig[5].ethUsdPriceFeed;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId].ethUsdPriceFeed;
  }

  log(ethUsdPriceFeedAddress);
  const args = [ethUsdPriceFeedAddress];
  log("args", args);
  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  log("----------------------------------------------------");
  log("Deploying FundMe and waiting for confirmations...");
  log(`FundMe deployed at ${fundMe.address}`);
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(fundMe.address, [ethUsdPriceFeedAddress]);
  }
};

module.exports.tags = ["all", "fundMe"];
