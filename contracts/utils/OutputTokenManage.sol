pragma solidity ^0.5.0;

import "./Context.sol";
import "../access/roles/OutputManagerRole.sol";

contract OutputTokenManage is Context, OutputManagerRole {

    address internal activeManager;

    event ActiveOutputMangerSet(address activeManager);

    constructor () internal {
        setActive();
    }

    /**
     * @dev Set an OutputManager as the active manager 
     * for transferFrom allowance and distribution.
     */
    function setActive() public onlyOutputManager {
        activeManager = _msgSender();

        emit ActiveOutputMangerSet(_msgSender());
    }

    function getActiveManager() public view returns (address) {
        return activeManager;
    }
}