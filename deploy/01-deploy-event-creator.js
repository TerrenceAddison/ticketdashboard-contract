const { network } = require("hardhat");
const {
  developmentChains,
  networkConfig,
  VERIFICATION_BLOCK_CONFIRMATIONS,
} = require("../helper-hardhat.config");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;

  const chainId = network.config.chainId;

  var priceFeedAddress;
  if (developmentChains.includes(network.name)) {
    const aggregator = await deployments.get("MockV3Aggregator");
    priceFeedAddress = aggregator.address;
  } else {
    priceFeedAddress = networkConfig[chainId]["priceFeed"];
  }
  const service = developmentChains.includes(network.name)
    ? deployer
    : deployer;
  log("Await deployments .............");
  const args = [priceFeedAddress, service];
  const EventCreator = await deploy("EventCreator", {
    from: deployer,
    log: true,
    args: args,
    waitConfirmations: developmentChains.includes(network.name)
      ? 1
      : VERIFICATION_BLOCK_CONFIRMATIONS,
  });
  log(`Contract deployed to ${EventCreator.address} 🥳🥳`);
};
module.exports.tags = ["all", "eventCreator"];
