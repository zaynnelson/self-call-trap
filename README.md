# SelfCallTrap

A Solidity smart contract trap designed to detect and respond to self-call transactions - scenarios where a contract or address calls itself with calldata.

## Overview

SelfCallTrap is an implementation of the ITrap interface from the Drosera contracts framework. It monitors blockchain transactions to identify potentially suspicious self-call patterns that could indicate malicious activity or exploitation attempts.

## Contract Details

- **License**: MIT
- **Solidity Version**: ^0.8.20
- **Interface**: ITrap (from drosera-contracts)

## Use Cases

### 1. **Reentrancy Attack Detection**
Detects contracts that call themselves recursively, which is a common pattern in reentrancy attacks where malicious contracts exploit state inconsistencies.

**Example Scenario**: A DeFi protocol being exploited through recursive calls to withdraw functions before balance updates are finalized.

### 2. **Smart Contract Security Monitoring**
Monitors for unusual self-referential behavior that could indicate:
- Contract upgrades gone wrong
- Proxy contract misconfigurations  
- Malicious contract deployments

### 3. **DeFi Protocol Protection**
Protects decentralized finance applications by flagging:
- Flash loan attack patterns
- Arbitrage bot exploits
- Price manipulation attempts through self-calls

### 4. **Automated Incident Response**
Triggers automated responses when suspicious self-call patterns are detected:
- Circuit breakers activation
- Transaction blocking
- Alert notifications to security teams

### 5. **Compliance and Auditing**
Provides audit trails for:
- Regulatory compliance monitoring
- Post-incident analysis
- Smart contract behavior verification

### 6. **MEV (Maximal Extractable Value) Detection**
Identifies sophisticated MEV strategies that use self-calls to:
- Manipulate transaction ordering
- Extract value from other users' transactions
- Execute complex arbitrage strategies

## How It Works

### Data Collection
The `collect()` function returns the deployer's wallet address for identification purposes.

### Detection Logic
The `shouldRespond()` function analyzes transaction data to determine if a response is needed:

1. **Input Validation**: Ensures minimum required data elements (from/to addresses)
2. **Address Extraction**: Decodes sender and receiver addresses from transaction data
3. **Self-Call Detection**: Identifies when `fromAddress == toAddress` (excluding zero address)
4. **Calldata Analysis**: Checks if the transaction contains calldata (indicating function execution)
5. **Response Decision**: Triggers when both self-call and calldata conditions are met

### Response Conditions

**Triggers Response When**:
- Transaction sender equals receiver (self-call)
- Transaction contains calldata (function execution)
- Both addresses are non-zero

**No Response When**:
- Different sender/receiver addresses
- No calldata present
- Invalid data format
- Zero addresses involved

## Integration Examples

### Security Monitoring System
```solidity
// Deploy trap in monitoring infrastructure
SelfCallTrap trap = new SelfCallTrap();

// Monitor transactions
bytes[] memory txData = [senderBytes, receiverBytes, calldataLengthBytes];
(bool shouldAlert, bytes memory reason) = trap.shouldRespond(txData);

if (shouldAlert) {
    // Trigger security response
    handleSecurityAlert(reason);
}
```

### DeFi Protocol Integration
```solidity
// Use in protocol's security layer
modifier checkSelfCall() {
    bytes[] memory currentTxData = getCurrentTransactionData();
    (bool isSuspicious, ) = selfCallTrap.shouldRespond(currentTxData);
    require(!isSuspicious, "Suspicious self-call detected");
    _;
}
```

## Error Handling

The contract provides descriptive error messages for various failure scenarios:
- `"Need at least 2 elements: from and to addresses"`
- `"Invalid fromAddress data length"`
- `"Invalid toAddress data length"`

## Security Considerations

1. **False Positives**: Legitimate contracts may perform self-calls for valid reasons (upgrades, internal state management)
2. **Data Validation**: Always validates input data format and length before processing
3. **Gas Efficiency**: Uses view functions where possible to minimize gas costs
4. **Access Control**: Constructor sets deployer as the identified wallet for tracking