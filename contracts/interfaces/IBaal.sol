// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "./IBaalToken.sol";

interface IBaal {
    function shamans(address shaman) external returns(uint256);
    function isAdmin(address shaman) external returns(bool);
    function isManager(address shaman) external returns(bool);
    function isGovernor(address shaman) external returns(bool);
    function target() external returns(address);
    function lootToken() external returns(IBaalToken);
    function sharesToken() external returns(IBaalToken);
}
