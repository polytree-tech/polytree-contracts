pragma solidity ^0.5.0;

import "../utils/Context.sol";
import "./TokenMigrate.sol";

/**
 * @dev Extension of {TokenMigrate} that allows token holders to migrate 
 * thier tokens from an input ERC20 contract to an output ERC20 contract
 * an a standard one-to-one basis.
 */
contract StandardMigration is Context, TokenMigrate {

    constructor () internal { }

    function migrate() public returns (bool) {
        uint256 inputAllowance = inputToken().allowance(_msgSender(), address(this));
        uint256 outputAllowance = outputToken().allowance(activeManager, address(this));
        require(inputAllowance > 0, "StandardMigration: no input allowance");
        require(outputAllowance > 0, "StandardMigration: no output allowance");
        require(outputAllowance >= inputAllowance, "StandardMigration: output allowance is less than the input allowance");

        _migrate(_msgSender(), inputAllowance, inputAllowance);

        return true;
    }   

}