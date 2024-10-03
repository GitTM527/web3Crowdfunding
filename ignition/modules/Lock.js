const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("CrowdfundingModule", (m) => {

  const Crowdfunding = m.contract("Crowdfunding");

  return { Crowdfunding };
});