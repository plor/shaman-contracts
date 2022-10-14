// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

// add dependencies here

contract DuesShaman is ReentrencyGuard {

    bool public initialized;
    DuesShamanSummoner factory;

    function init() public {
        require(!initialized, "already initialized");
        initialized = true;
        factory = DuesShamanSummoner(msg.sender);
    }

    function initTemplate() public {
        intialized = true;
    }

    function payDues(uint256 _value) public nonReentrant {

    }

}
