// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SelfCallResponseTrap {
    struct DetectionLog {
        string alertType;
        address suspiciousWallet;
        uint256 timestamp;
        string description;
        bool isActive;
    }
    
    DetectionLog public detection;
    address private owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function response(bytes memory responseData) external onlyOwner {
        (string memory alertType, address suspiciousAddr) = 
            abi.decode(responseData, (string, address));
        
        detection = DetectionLog({
            alertType: alertType,
            suspiciousWallet: suspiciousAddr,
            timestamp: block.timestamp,
            description: "Self-call detected with calldata",
            isActive: true
        });
    }
}