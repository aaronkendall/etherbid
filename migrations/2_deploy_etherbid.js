const EtherBid = artifacts.require("./EtherBid.sol");

module.exports = function(deployer) {
  deployer.deploy(EtherBid);
};
