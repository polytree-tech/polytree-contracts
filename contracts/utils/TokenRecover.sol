
pragma solidity ^0.5.0;

import "../ERC20/SafeERC20.sol";

import "../ERC20/IERC20.sol";
import "./Context.sol";
import "../access/roles/RecoverRole.sol";

contract TokenRecover is Context, RecoverRole {
    using SafeERC20 for IERC20;

    event RecoveredTokens( address recoverer, address tokenAddress, uint256 tokenAmount);

    constructor () internal { }

    /**
     * @dev internal recover function
     * @param token The token contract address
     * @param tokenAmount Number of tokens to be sent
     */
    function _recoverERC20(IERC20 token, uint256 tokenAmount) internal onlyRecoverer {

        token.safeTransfer(_msgSender(), tokenAmount);

        emit RecoveredTokens(_msgSender(), address(token), tokenAmount);
    }

}