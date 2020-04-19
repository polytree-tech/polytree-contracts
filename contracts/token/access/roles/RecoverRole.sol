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

// THIS CONTRACT HAS BEEN CHANGED BY THE NAME OF THE ROLE
pragma solidity ^0.5.0;

import "../../utils/Context.sol";
import "../Roles.sol";

contract RecoverRole is Context {
    using Roles for Roles.Role;

    event RecovererAdded(address indexed account);
    event RecovererRemoved(address indexed account);

    Roles.Role private _recoverers;

    constructor () internal {
        _addRecoverer(_msgSender());
    }

    modifier onlyRecoverer() {
        require(isRecoverer(_msgSender()), "RecovererRole: caller does not have the Recoverer role");
        _;
    }

    function isRecoverer(address account) public view returns (bool) {
        return _recoverers.has(account);
    }

    function addRecoverer(address account) public onlyRecoverer {
        _addRecoverer(account);
    }

    function renounceRecoverer() public {
        _removeRecoverer(_msgSender());
    }

    function _addRecoverer(address account) internal {
        _recoverers.add(account);
        emit RecovererAdded(account);
    }

    function _removeRecoverer(address account) internal {
        _recoverers.remove(account);
        emit RecovererRemoved(account);
    }
}