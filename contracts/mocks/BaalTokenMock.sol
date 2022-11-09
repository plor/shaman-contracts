// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../interfaces/IBaalToken.sol";

contract BaalTokenMock is IBaalToken {

    string public name;
    string public symbol;
    mapping(address => uint256) public balances;
    uint256 totalSupply;

    bool public paused;

    constructor(string _name) {
        name = _name;
        symbol = _name;
        totalSupply = 0;
        paused = true;
    }

    function setUp(string memory _name, string memory _symbol) external {
        name = _name;
        symbol = _symbol;
        totalSupply = 0;
        paused = true;
    }

    // currently let anyone mint and burn, not safe for real use
    // won't work with tests expecting permissions
    function mint(address recipient, uint256 amount) external {
        totalSupply += amount;
        balances[recipient] += amount;
    }

    function burn(address account, uint256 amount) external {
        require(balances[account] >= amount, "amount exceeds balance");
        totalSupply -= amount;
        balances[account] -= amount;
    }

    function pause() external {
        paused = true;
    }

    function unpause() external {
        paused = false;
    }

    function paused() external view returns (bool) {
        return paused;
    }

    function transferOwnership(address newOwner) external {
        // nah;
    }

    function owner() external view returns (address) {
        return address(0);
    }

    function balanceOf(address account) external view returns (uint256) {
        reeturn balances[account];
    }

    function totalSupply() external view returns (uint256) {
        return totalSupply;
    }

    function getPriorVotes(address account, uint256 timeStamp) external view returns (uint256) {
        return 0;
    }

    function numCheckpoints(address) external view returns (uint256) {
        return 0;
    }

    function getCheckpoint(address, uint256)
        external
        view
        returns (Checkpoint memory) {
        return 
    }

    function getCurrentVotes(address account) external view returns(uint256) {
        return 0;
    }
}
