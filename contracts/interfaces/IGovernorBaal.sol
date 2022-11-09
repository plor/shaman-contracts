// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "./IBaal.sol";

interface IGovernorBaal is IBaal {
    function setGovernanceConfig(bytes memory _governanceConfig) external;
}
