const BN = require('bn.js');
const ERC20Token1 = artifacts.require("ERC20Token");
const ERC20Token2 = artifacts.require("ERC20Token");
const ERC20Migrate = artifacts.require("ERC20Migrate");


module.exports = async function (deployer) {
    // deployer.deploy(ERC20Token1, {overwrite: false}).then( function() {
    //     deployer.deploy(ERC20Token2).then( function() {
    //         deployer.deploy(ERC20Migrate, ERC20Token1.address, ERC20Token2.address);
    //     });
    // });
    
}