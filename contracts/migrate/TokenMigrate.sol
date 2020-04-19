pragma solidity ^0.5.0;
// pragma experimental ABIEncoderV2;

import "../utils/SafeMath.sol";
import "../ERC20/SafeERC20.sol";

import "../utils/Context.sol";
import "../utils/OutputTokenManage.sol";
import "../utils/TokenRecover.sol";
import "../ERC20/IERC20.sol";

contract TokenMigrate is Context, OutputTokenManage, TokenRecover{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private _inputToken;
    address private _outputToken;
    uint256 private _tokensMigrated;
    uint256 private _tokensDistributed;

    struct MigrationRecord {
        uint256 migratedTokens;
        uint256 distributedTokens;
    }

    event Migrated(address indexed migrator, uint256 migratedTokens, uint256 distributedTokens);

    mapping(address => MigrationRecord) private _migrationRecords;
    
    /**
    * @dev ERC20 token migration contract
    *
    * Requirments -
    *
    *   Both the input and output token cntracts must be ERC20 implementations 
    *   and match the standard {IERC20} interface specification.
    *
    *   There must be a migration managing account hoding tokens of the output ERC20 
    *   contract. That managing account must give this migration contract transferFrom 
    *   allowance for any amount of tokens that will be distributed via migration
    *   
    *   The migrating account must give this migration contract an amount of
    *   transferFrom allowance on the input ERC20 contract before calling migrate()
    *
    */
    constructor (IERC20 inputToken, IERC20 outputToken) internal {   
        require( address(inputToken) != address(0), "TokenMigrate: inputToken cannot be 0x00");
        require( address(outputToken) != address(0), "TokenMigrate: outputToken cannot be 0x00");
        require( address(inputToken) != address(outputToken), "TokenMigrate: inputToken and outputToken cannot be the same contract");
        
        _inputToken = address(inputToken);
        _outputToken = address(outputToken);
    }

    function inputToken() public view returns (IERC20) {
        return IERC20(_inputToken);
    }
    
    function outputToken() public view returns (IERC20) {
        return IERC20(_outputToken);
    }

    function tokensMigrated() public view returns (uint256) {
        return _tokensMigrated;
    }

    function tokensDistributed() public view returns (uint256) {
        return _tokensDistributed;
    }

    function getMigrationRecord(address migrator) public view returns (uint256, uint256) {
        return (_migrationRecords[migrator].migratedTokens, _migrationRecords[migrator].distributedTokens);
    }

    /**
     * @dev internal recover function
     * @param token The token contract address
     * @param tokenAmount Number of tokens to be recovered
     */
    function recoverERC20(IERC20 token, uint256 tokenAmount) public onlyRecoverer {
        uint256 available;

        if(address(token) == address(inputToken())) {
            available = token.balanceOf(address(this)).sub(_tokensMigrated);
        } else {
            available = token.balanceOf(address(this));
        }

        require(tokenAmount <= available, "TokenRecover: tokenAmount is greater than the available recovery amount");

        _recoverERC20(token, tokenAmount);
    }

    function _migrate(address migrator, uint256 inputAmount, uint256 outputAmount) internal returns (bool) { 
        require(migrator != activeManager, "TokenMigrate: migrator cannot be the distribution token approval holder");
        _tokensMigrated = _tokensMigrated.add(inputAmount);
        _tokensDistributed = _tokensDistributed.add(outputAmount);

        _migrationRecords[migrator].migratedTokens = _migrationRecords[migrator].migratedTokens.add(inputAmount);
        _migrationRecords[migrator].distributedTokens = _migrationRecords[migrator].distributedTokens.add(outputAmount);

        inputToken().safeTransferFrom(_msgSender(), address(this), inputAmount);

        outputToken().safeTransferFrom(activeManager, _msgSender(), outputAmount);

        emit Migrated(_msgSender(), inputAmount, outputAmount);
    }
    
}