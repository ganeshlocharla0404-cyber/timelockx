
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TimeLockx
 * @dev A simple time-lock smart contract that allows users to lock ETH 
 * and withdraw it only after the lock period has expired.
 */
contract TimeLockx {
    struct Lock {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Lock) public locks;

    event Locked(address indexed user, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @dev Lock ETH for a given duration (in seconds).
     * @param _duration Duration in seconds to lock the funds.
     */
    function lockFunds(uint256 _duration) external payable {
        require(msg.value > 0, "Must send ETH to lock");
        require(locks[msg.sender].amount == 0, "Existing lock active");

        uint256 unlockTime = block.timestamp + _duration;

        locks[msg.sender] = Lock({
            amount: msg.value,
            unlockTime: unlockTime
        });

        emit Locked(msg.sender, msg.value, unlockTime);
    }

    /**
     * @dev Withdraw locked ETH after unlock time has passed.
     */
    function withdrawFunds() external {
        Lock storage userLock = locks[msg.sender];
        require(userLock.amount > 0, "No funds locked");
        require(block.timestamp >= userLock.unlockTime, "Funds still locked");

        uint256 amount = userLock.amount;
        userLock.amount = 0;

        payable(msg.sender).transfer(amount);

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev View remaining lock time for the caller.
     */
    function getRemainingTime() external view returns (uint256) {
        Lock memory userLock = locks[msg.sender];
        if (block.timestamp >= userLock.unlockTime) {
            return 0;
        }
        return userLock.unlockTime - block.timestamp;
    }
}
