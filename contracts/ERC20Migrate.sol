pragma solidity ^0.5.0;

import "./token_migrate/TokenMigrate.sol";
import "./token_migrate/StandardMigration.sol";

contract ERC20Migrate is TokenMigrate, StandardMigration {
    
    constructor (IERC20 migrateFrom, IERC20 migrateTo) public 
    TokenMigrate(migrateFrom, migrateTo)
    {}
}