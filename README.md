# 🧠 SelfCall Trap — Drosera Network

This repository implements a **Drosera-compatible Trap/Responder pair** designed to detect and respond to **self-call patterns** — when a contract invokes itself (i.e., `from == to`) with non-empty calldata.
This behavior often indicates automated proxy initialization, recursive logic bugs, or potential malicious dusting-style self-executions.

---

## 📘 Overview

The **SelfCallTrap** system is composed of three on-chain components:

1. **`SelfCallRegistry.sol`** — Keeps track of self-call events detected off-chain.
2. **`SelfCallTrap.sol`** — A Drosera Trap that queries the registry and determines if an alert should be raised.
3. **`SelfCallResponseTrap.sol`** — A simple responder that logs detections and emits on-chain alerts.

---

## 🏗️ Architecture

```
+-------------------+
|  Off-chain Script |
|  (Detector)       |
|-------------------|
| Watches mempool   |
| or tx history     |
| Detects self-call |
| Encodes ID        |
| Calls registry.flag() |
+---------+---------+
          |
          v
+-------------------+
| SelfCallRegistry  |
|-------------------|
| Stores flagged ID |
| Emits event       |
+---------+---------+
          |
          v
+-------------------+
| SelfCallTrap      |
|-------------------|
| Queries registry  |
| via .flagged(id)  |
| If true → responds|
+---------+---------+
          |
          v
+-------------------+
| SelfCallResponse  |
|-------------------|
| Logs alert        |
| Emits event       |
+-------------------+
```

---

## ⚙️ Smart Contracts

### `SelfCallRegistry.sol`

Stores self-call detection results flagged by the off-chain detector.
Each detection generates a unique `id` based on:

```solidity
keccak256(abi.encode(wallet, calldataLength, blockNumber))
```

### `SelfCallTrap.sol`

Queries the registry and decides whether to trigger a Drosera response.
The ID must match the one flagged off-chain:

```solidity
bytes32 id = keccak256(abi.encode(msg.sender, msg.data.length, block.number));
```

### `SelfCallResponseTrap.sol`

Receives Drosera Executor callbacks, records the detection on-chain, and emits `SelfCallHandled`.

---

## 🔍 Off-Chain Detector (Example Flow)

The off-chain detector script should:

1. Monitor transactions (via RPC or mempool).
2. Identify transactions where `tx.from == tx.to`.
3. Check that `tx.input.length > 0`.
4. Compute the detection ID:

   ```js
   const id = keccak256(abi.encode(from, calldataLen, blockNumber))
   ```
5. Call `SelfCallRegistry.flag(wallet, calldataLen, blockNumber)`.

Once flagged, the Trap will detect it on-chain and signal the responder.

---

## 🧩 Example Use Cases

* Detect **recursive or accidental contract self-calls**
* Monitor **proxy or factory patterns** making self-invocations
* Identify **potential dusting or bait behavior** from on-chain automation

---

## 🚀 Deployment Order

1. Deploy `SelfCallRegistry.sol`
2. Deploy `SelfCallTrap.sol`, update the `REGISTRY` constant address.
3. Deploy `SelfCallResponseTrap.sol`
4. Register both Trap and Responder in Drosera Network.
