// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract SelfCallTrap is ITrap {
    address private myWallet;
    
    constructor() {
        myWallet = msg.sender;
    }
    
    function collect() external view returns (bytes memory) {
        return abi.encode(myWallet);
    }
    
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, abi.encode("Need at least 2 elements: from and to addresses"));
        }
        
        address fromAddress;
        address toAddress;
        uint256 calldataLength;
        
        if (data[0].length == 32) {
            fromAddress = abi.decode(data[0], (address));
        } else {
            return (false, abi.encode("Invalid `fromAddress` data length"));
        }

        if (data[1].length == 32) {
            toAddress = abi.decode(data[1], (address));
        } else {
            return (false, abi.encode("Invalid `toAddress` data length"));
        }
        
        if (data.length > 2 && data[2].length == 32) {
             calldataLength = abi.decode(data[2], (uint256));
        }
        
        bool isSelfCall = (fromAddress == toAddress && fromAddress != address(0));
        bool hasCalldata = (calldataLength > 0);
        
        if (isSelfCall && hasCalldata) {
            return (true, abi.encode("SELF_CALL_DETECTED", fromAddress));
        }
        
        return (false, abi.encode("Safe"));
    }
}