// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @notice QuillShield UI/audit fixture. Not a production contract.
contract AtlasRewards {
    address public immutable owner = msg.sender;
    mapping(address => uint256) public claimable;
    uint256 public totalAllocated;

    function allocate(address account, uint256 amount) external {
        require(msg.sender == owner, "owner only");
        require(account != address(0) && amount > 0, "invalid allocation");
        require(totalAllocated + amount <= address(this).balance, "insufficient reserves");
        claimable[account] += amount;
        totalAllocated += amount;
    }

    function claim() external {
        uint256 amount = claimable[msg.sender];
        require(amount > 0, "nothing to claim");
        claimable[msg.sender] = 0;
        totalAllocated -= amount;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");
    }

    function sweepSurplus(address payable recipient, uint256 amount) external {
        require(msg.sender == owner, "owner only");
        require(address(this).balance >= totalAllocated, "insolvent");
        require(amount <= address(this).balance - totalAllocated, "reserved funds");
        (bool ok,) = recipient.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
