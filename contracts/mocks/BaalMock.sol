// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IBaal.sol";

contract BaalMock is IBaal {

    address public target;
    IBaalToken public lootToken;
    IBaalToken public sharesToken;

    constructor() {
        lootToken = new BaalTokenMock("MOCKLOOT");
        sharesToken = new BaalTokenMock("MOCKSHARE");
    }

    // All shamans have all permissions for testing
    // The mock can allow alternates if needed
    function shamans(address shaman) external returns(uint256) {
        return 7;
    }

    function isAdmin(address shaman) external returns(bool) {
        return true;
    }

    function isManager(address shaman) external returns(bool) {
        return true;
    }

    function isGovernor(address shaman) external returns(bool) {
        return true;
    }

    function setTarget(address _target) {
        target = _target;
    }

    function mintShares(address[] calldata to, uint256[] calldata amount) external {
        for (uint256 i = 0; i < to.length; i++) {
            sharesToken.mint(to[i], amount[i]);
        }
    }

    function burnShares(address[] calldata from, uint256[] calldata amount) external {
        for (uint256 i = 0; i < to.length; i++) {
            sharesToken.burn(from[i], amount[i]);
        }
    }

    function mintLoot(address[] calldata to, uint256[] calldata amount) external {
        for (uint256 i = 0; i < to.length; i++) {
            lootToken.mint(to[i], amount[i]);
        }
    }

    function burnLoot(address[] calldata from, uint256[] calldata amount) external {
        for (uint256 i = 0; i < to.length; i++) {
            lootToken.burn(from[i], amount[i]);
        }
    }

    function setAdminConfig(bool pauseShares, bool pauseLoot) external {
        if (pauseShares != sharesToken.paused()) {
            if (pauseShares) {
                sharesToken.pause();
            } else {
                sharesToken.unpause();
            }
        }

        if (pauseLoot != lootToken.paused()) {
            if (pauseLoot) {
                lootToken.pause();
            } else {
                lootToken.unpause();
            }
        }
    }

    // TODO governance config not yet implemented on mock
    function setGovernanceConfig(bytes memory _governanceConfig) external {
        // nothing happens
    }
} 
