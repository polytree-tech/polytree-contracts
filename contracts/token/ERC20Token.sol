pragma solidity ^0.5.0;

import "./utils/Context.sol";
import "./utils/TokenRecover.sol";
import "./ERC20/ERC20.sol";
import "./features/ERC20Detailed.sol";
import "./features/ERC20Burnable.sol";
import "./features/ERC20Pausable.sol";
import "./features/ERC20VotingMintable.sol";

contract ERC20Token is Context, TokenRecover, ERC20, ERC20Detailed, ERC20Burnable, ERC20VotingMintable, ERC20Pausable{
    
    string private _issuingCountry = "Singapore";
    string private _issuingCompany = "Polytree LLC";
    uint256 private _initialSupply = 1000000000;
    
    constructor () public ERC20Detailed
    ( "ERC20 Test Token", "ETT", 18 ) 
    { _mint(_msgSender(), _initialSupply * (10 ** uint256(decimals()))); }
    
    function issuingCountry() public view returns ( string memory ){
        return _issuingCountry;
    }
    
    function issuingCompany() public view returns ( string memory ){
        return _issuingCompany;
    }

    function initialSupply() public view returns ( uint256 ){
        return _initialSupply;
    }
    
}