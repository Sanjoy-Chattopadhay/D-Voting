# 🗳️ Vote Smart Contract

A simple blockchain-based voting system that allows candidates to register, voters to vote, and the commissioner to declare results securely and transparently.

---

## 📄 Contract Summary

This smart contract enables:

- Candidate registration (max 2 candidates)
- Voter registration
- Voting within a defined time window
- Emergency stop functionality
- Winner selection after voting ends

Built with Solidity for Ethereum-compatible blockchains.

---

## ⚙️ Features

- ✅ Role-based access: only the Election Commissioner can manage voting time and results.
- ✅ One person, one vote: registered voters can vote once.
- ✅ Secure and verifiable: immutable voter and candidate records.
- ✅ Emergency pause: commissioner can halt voting if needed.

---

## 🏗️ Smart Contract Architecture

### Structs

- `Voter`:
  - Name, age, gender
  - Voter ID
  - Voted candidate ID
  - Address

- `Candidate`:
  - Name, party, age, gender
  - Candidate ID
  - Address
  - Vote count

---

## 🛠️ Functions

### 🔐 Access Control

- `onlyCommissioner`: Restricts function to the commissioner (contract deployer).
- `isVotingOver`: Allows voting only during active period and not stopped.

### 🧾 Registration

- `candidateRegister(...)`: Register a new candidate (max 2 allowed).
- `voterRegister(...)`: Register a new voter.

### 📃 Retrieval

- `candidateList()`: Get all registered candidates.
- `voterList()`: Get all registered voters.
- `votingStatus()`: Get current voting status message.

### 🗓️ Voting Setup

- `voteTime(startTime, duration)`: Set voting time window.

### 🆘 Emergency

- `emergency()`: Pause voting due to emergency.

### ✅ Voting & Results

- `vote(voterId, candidateId)`: Submit a vote.
- `result()`: Determine the winner based on vote count.

---

## 🧪 Requirements

- Solidity `>=0.5.0 <0.9.0`
- Ethereum-compatible environment (Remix, Hardhat, Truffle)

---

## 🧑‍⚖️ Deployment

Deploy the contract with your address acting as the **Election Commissioner**.

```bash
electionCommission = msg.sender;
