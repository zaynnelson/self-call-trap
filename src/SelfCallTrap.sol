// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface ISelfCallRegistry {
    function flagged(bytes32 id) external view returns (bool);
}

contract SelfCallTrap is ITrap {
    address public constant REGISTRY = 0x0000000000000000000000000000000000000000;

    struct CollectOutput {
        uint256 blockNumber;
        bytes32 lastId;
        bool isFlagged;
    }

    function collect() external view override returns (bytes memory) {
        bytes32 id = keccak256(
            abi.encode(msg.sender, msg.data.length, block.number)
        );

        bool f = ISelfCallRegistry(REGISTRY).flagged(id);

        return abi.encode(
            CollectOutput({
                blockNumber: block.number,
                lastId: id,
                isFlagged: f
            })
        );
    }

    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (data.length == 0) return (false, "");

        CollectOutput memory sample = abi.decode(data[0], (CollectOutput));

        if (sample.isFlagged) {
            return (true, abi.encode(sample.lastId));
        }

        return (false, "");
    }
}
