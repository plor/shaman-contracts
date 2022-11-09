// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "./IBaal.sol";

interface IAdminBaal is IBaal {
    function setAdminConfig(bool pauseShares, bool pauseLoot) external;
}
