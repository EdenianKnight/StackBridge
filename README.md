# sBTC Bridge Project

## Description

This project implements a cross-chain bridge facilitating the transfer of sBTC (Stacks Bitcoin) between the Stacks Layer 2 blockchain and the Bitcoin Layer 1 blockchain. The primary goal is to unlock Bitcoin liquidity for use in Decentralized Finance (DeFi) and Traditional Finance (TradFi) applications built on Stacks, leveraging the security of Bitcoin settlement.

The bridge operates via a lock-and-mint mechanism:
* Users lock Bitcoin (via mechanisms not defined in *this* specific contract, but assumed) which is verified by an oracle.
* The bridge contract on Stacks mints a corresponding amount of sBTC tokens.
* To unlock Bitcoin, users burn sBTC tokens on Stacks, and the bridge facilitates the release of the underlying Bitcoin (verified by the oracle).

## Key Features

* **Interoperability:** Enables value transfer between Bitcoin L1 and Stacks L2.
* **Liquidity Provision:** Unlocks Bitcoin liquidity for Stacks-based applications.
* **Smart Contract System:** Uses Clarity smart contracts (`sbtc-bridge.clar`, `sbtc-token.clar`) for managing the locking, minting, burning, and unlocking processes on the Stacks side.
* **Security:** Leverages Stacks' security model, where transactions are ultimately settled on the Bitcoin blockchain.
* **Oracle Dependency:** Relies on an external (or potentially decentralized) oracle system to verify Bitcoin-side transactions (locking/unlocking). *(Note: The oracle interaction logic is simplified in the current contract version)*.
* **Signature Verification:** Includes placeholders for verifying user signatures related to Bitcoin transactions. *(Note: The current implementation is a placeholder and **not secure** for production)*.

## Project Structure

sbtc-bridge-project/├── Clarinet.toml       # Project configuration, contract definitions, dependencies├── contracts/          # Clarity smart contracts│   ├── sbtc-bridge.clar  # Main bridge logic contract│   └── sbtc-token.clar   # Basic sBTC Fungible Token contract (placeholder)├── settings/           # Network-specific deployment settings│   ├── Devnet.toml│   ├── Mainnet.toml│   └── Testnet.toml└── tests/              # Unit tests for the smart contracts (TypeScript)
## Contracts

* **`sbtc-token.clar`**: A basic implementation of an sBTC fungible token. It handles minting, burning, and transfers on the Stacks layer. In a production environment, this should adhere to the SIP-010 Fungible Token standard.
* **`sbtc-bridge.clar`**: The core logic for the bridge. It interacts with the `sbtc-token` contract and manages the state related to locked balances and transaction verification (pending secure implementation). It includes functions for:
    * Locking BTC equivalent and minting sBTC (`lock-sbtc`)
    * Burning sBTC and initiating BTC unlock (`unlock-sbtc`)
    * Oracle and bridge state management.

## Getting Started

### Prerequisites

* **Node.js and npm (or yarn):** Download from [https://nodejs.org/](https://nodejs.org/)
* **Clarinet:** Install using the official guide: [https://docs.stacks.co/clarity/tools/clarinet/getting-started#installation](https://docs.stacks.co/clarity/tools/clarinet/getting-started#installation)
    * Verify installation: `clarinet --version`

### Setup

1.  **Clone the Repository (if applicable) or Create Project:**
    ```bash
    # If cloning:
    # git clone <repository-url>
    # cd sbtc-bridge-project

    # If creating manually:
    clarinet new sbtc-bridge-project
    cd sbtc-bridge-project
    # Manually add sbtc-token.clar and sbtc-bridge.clar to the contracts/ directory
    # Configure Clarinet.toml as shown below
    ```

2.  **Configure `Clarinet.toml`:** Ensure your `Clarinet.toml` file defines both contracts and their dependency:
    ```toml
    [project]
    name = "sbtc-bridge-project"
    # ... other project details ...
    requirements = []

    [contracts.sbtc-token]
    path = "contracts/sbtc-token.clar"
    depends_on = []

    [contracts.sbtc-bridge]
    path = "contracts/sbtc-bridge.clar"
    depends_on = ["sbtc-token"] # Bridge depends on the token contract

    # ... rest of the file ...
    ```

## Usage

The primary interactions with the bridge contract (once deployed) involve locking and unlocking assets.

* **Locking BTC / Minting sBTC:**
    * A user initiates a Bitcoin transaction to lock BTC (details depend on the specific off-chain/L1 mechanism).
    * An oracle verifies this transaction.
    * The user (or oracle) calls the `lock-sbtc` function on the `sbtc-bridge.clar` contract on Stacks, providing the amount, a unique Bitcoin transaction ID (`tx-id`), and a valid signature (or proof).
    * The bridge contract verifies the details (including the signature - *currently placeholder*) and calls the `mint` function on the `sbtc-token.clar` contract to issue sBTC to the user's Stacks address.

* **Unlocking BTC / Burning sBTC:**
    * A user calls the `unlock-sbtc` function on the `sbtc-bridge.clar` contract, specifying the amount of sBTC to burn, a unique identifier (`tx-id` for tracking), and a signature.
    * The bridge contract verifies the user has sufficient sBTC balance and calls the `burn` function on the `sbtc-token.clar` contract.
    * Upon successful burning, the bridge signals (via events or state changes) that the corresponding Bitcoin on L1 can be released (details depend on the L1 mechanism and oracle).

## Development

### Check Contracts

Verify the syntax and types of the Clarity contracts:

```bash
clarinet check
Run TestsExecute the unit tests located in the tests/ directory (requires writing tests first):clarinet test
Important ConsiderationsSecurity - Signature Verification: The current is-valid-signature function in sbtc-bridge.clar is a placeholder and insecure. A production implementation must replace this with robust cryptographic verification (e.g., using secp256k1-recover and proper hashing) linked to the Bitcoin transaction proof.Security - Oracle: The reliability and security of the oracle mechanism used to verify Bitcoin-side events are paramount to the overall security of the bridge. The current contract assumes an oracle exists and can authorize actions but doesn't implement the oracle itself.sBTC Token Standard: The provided sbtc-token.clar is basic. For real-world use and compatibility with DeFi protocols, it should be upgraded to comply with the SIP-010 Fungible Token standard.Bitcoin Transaction Handling: The contracts do not parse or deeply verify Bitcoin transaction details on-chain. This logic is assumed to be handled by the oracle or off-chain components providing the tx-id and proofs.Gas Fees: Be mindful of transaction costs (gas fees) on the Stacks network when interacting with the bridge.ContributingContributions are welcome! Please follow standard practices like creating issues for bugs or feature requests and submitting pull requests for changes. (Add more specific contribution guidelines if needed).License(Specify the license, e.g., MIT License)MIT License

Copyright (c) [Year] [Your Name or Organization]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.