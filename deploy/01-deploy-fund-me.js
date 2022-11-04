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
      ehtUSDAggrigator.address || "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e";
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId].ethUsdPriceFeed;
  }

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
