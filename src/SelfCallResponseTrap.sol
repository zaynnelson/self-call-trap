// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SelfCallResponseTrap {
    struct DetectionLog {
        bytes32 lastId;
        uint256 blockNumber;
        uint256 timestamp;
        bool isActive;
    }

    DetectionLog public detection;

    event SelfCallHandled(
        bytes32 lastId,
        uint256 blockNumber,
        uint256 timestamp
    );

    function response(bytes memory responseData) external {
        bytes32 lastId = abi.decode(responseData, (bytes32));

        detection = DetectionLog({
            lastId: lastId,
            blockNumber: block.number,
            timestamp: block.timestamp,
            isActive: true
        });

        emit SelfCallHandled(lastId, block.number, block.timestamp);
    }
}
