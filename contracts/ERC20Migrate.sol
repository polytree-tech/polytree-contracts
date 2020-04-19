pragma solidity ^0.5.0;

import "./migrate/TokenMigrate.sol";
import "./migrate/StandardMigration.sol";

contract ERC20Migrate is TokenMigrate, StandardMigration {
    
    constructor (IERC20 migrateFrom, IERC20 migrateTo) public 
    TokenMigrate(migrateFrom, migrateTo)
    {}
}