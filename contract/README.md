# Vaccine NFT Smart Contract (Soroban)

A Soroban smart contract for issuing and managing non-fungible tokens (NFTs) representing vaccination records on the Stellar blockchain.

## Overview

This contract implements an NFT collection where each token represents a specific vaccination event, storing immutable attributes such as vaccine name, batch number, expiration date, and administration date.

## Features

-   Mint NFTs with custom attributes (vaccine name, batch, dates)
-   Query token ownership and attributes
-   Transfer tokens between addresses
-   Admin-controlled minting
-   Immutable storage of vaccination data

## Prerequisites

-   Rust toolchain
-   Soroban CLI (`cargo install soroban-cli`)
-   Stellar testnet account with funds

## Installation

1. Install Soroban CLI:

    ```bash
    cargo install soroban-cli
    ```

2. Clone the repository and navigate to the contract directory:
    ```bash
    cd contract
    ```

## Building the Contract

```bash
# Build for release
cargo build --target wasm32-unknown-unknown --release
```

## Deploying to Testnet

1. Fund a testnet account if needed:

    ```bash
    soroban config identity fund --network testnet --account admin
    ```

2. Deploy the contract:

    ```bash
    soroban contract deploy \
      --wasm target/wasm32-unknown-unknown/release/hello_world.wasm \
      --source admin \
      --network testnet
    ```

3. Initialize the contract:
    ```bash
    soroban contract invoke \
      --id <CONTRACT_ID> \
      --source admin \
      --network testnet \
      -- \
      initialize \
      --admin <ADMIN_ADDRESS> \
      --name "VaccineNFT" \
      --symbol "VNFT"
    ```

## Contract Functions

### Initialization

-   `initialize(admin, name, symbol)`: Set up the contract with admin address and metadata

### Token Management

-   `mint_with_attrs(to, vaccine_name, batch, exp_date, taken_date)`: Mint a new NFT with vaccination attributes
-   `owner_of(token_id)`: Get the owner of a token
-   `get_attrs(token_id)`: Retrieve vaccination attributes for a token
-   `update_attrs(caller, token_id, ...)`: Update token attributes (owner only)
-   `transfer(from, to, token_id)`: Transfer token ownership

## Project Structure

-   `contracts/hello_world/src/lib.rs`: Main contract implementation
-   `contracts/hello_world/Cargo.toml`: Contract dependencies
-   `Cargo.toml`: Workspace configuration

## Dependencies

-   `soroban-sdk`: Soroban smart contract framework
-   `soroban-sdk/macros`: Contract macros and utilities

## Testing

```bash
# Run unit tests
cargo test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

ISC
