// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SelfCallRegistry {
    event SelfCallFlag(
        address indexed wallet,
        uint256 calldataLength,
        uint256 blockNumber,
        bytes32 id
    );

    mapping(bytes32 => bool) public flagged;

    function flag(
        address wallet,
        uint256 calldataLength,
        uint256 blockNumber
    ) external {
        bytes32 id = keccak256(
            abi.encode(wallet, calldataLength, blockNumber)
        );

        flagged[id] = true;

        emit SelfCallFlag(wallet, calldataLength, blockNumber, id);
    }
}
