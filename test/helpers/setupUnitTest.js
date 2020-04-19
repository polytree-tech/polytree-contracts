const contractArtifacts = require('./contractArtifacts');
const { BN } = require('./setup');

async function setUpUnitTest (accounts) {
  const [owner, manager, pauser, recoverer, ...others] = accounts;

  const SafeMathLib = await contractArtifacts.SafeMathLib.new();

  const libs = {
    SafeMathLib: SafeMathLib.address,
  };

  await contractArtifacts.ERC20Token.link(libs);
  await contractArtifacts.ERC20Migrate.link(libs);

  let ERC20Token1 = await contractArtifacts.ERC20Token.new({ from: owner });

  let ERC20Token2 = await contractArtifacts.ERC20Token.new({ from: owner });

  let ERC20Migrate = await contractArtifacts.ERC20Migrate.new(ERC20Token1.address, ERC20Token2.address, { from: owner });

  const contracts = {ERC20Token1: ERC20Token1, ERC20Token2: ERC20Token2, ERC20Migrate: ERC20Migrate};
  return { instances: contracts };
}

module.exports = {
  setUpUnitTest,
};