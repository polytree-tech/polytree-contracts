// The MIT License (MIT)

// Copyright (c) 2016-2019 zOS Global Limited

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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