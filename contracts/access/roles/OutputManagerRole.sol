pragma solidity ^0.5.0;

import "../../utils/Context.sol";
import "../Roles.sol";

contract OutputManagerRole is Context {
    using Roles for Roles.Role;

    event OutputManagerAdded(address indexed account);
    event OutputManagerRemoved(address indexed account);

    Roles.Role private _outputManagers;

    constructor () internal {
        _addOutputManager(_msgSender());
    }

    modifier onlyOutputManager() {
        require(isOutputManager(_msgSender()), "OutputManagerRole: caller does not have the OutputManager role");
        _;
    }

    function isOutputManager(address account) public view returns (bool) {
        return _outputManagers.has(account);
    }

    function addOutputManager(address account) public onlyOutputManager {
        _addOutputManager(account);
    }

    function renounceOutputManager() public {
        _removeOutputManager(_msgSender());
    }

    function _addOutputManager(address account) internal {
        _outputManagers.add(account);
        emit OutputManagerAdded(account);
    }

    function _removeOutputManager(address account) internal {
        _outputManagers.remove(account);
        emit OutputManagerRemoved(account);
    }
}