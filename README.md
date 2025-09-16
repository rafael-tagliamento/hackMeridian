# ImmuneChain Architecture & Blockchain Integration

> Version: 1.0 – Focus on: Smart Contract Soroban (Rust), Backend Express (TypeScript), Admin Web (React + Vite), User App (Flutter). **Python backend ignored as requested.**

---

## 1. Ecosystem Overview

ImmuneChain is a multi-platform ecosystem for issuing, distributing, and verifying **vaccination NFTs** and verifiable identities, using **Soroban/Stellar** as the trust layer.

Focused components:

-   **Smart Contract (Rust + Soroban)** – Issuance and management of vaccination NFTs with attributes (name, batch, validity, application date).
-   **Backend Express TypeScript** – API that orchestrates minting on the contract via `@stellar/stellar-sdk` and exposes REST endpoints.
-   **Admin Web (React)** – Interface for healthcare professionals: scans patient's signed QR identity and registers vaccination (future: calls NFT mint).
-   **User App (Flutter)** – Generates and signs digital identity (QR Code) with local Ed25519 key, allows viewing vaccination wallet and verifying records.

Macro flow (current MVP + intention):

1. User opens Flutter app → generates Stellar key pair locally → Identity QR Code (JSON + Ed25519 signature).
2. Professional (Admin Web) scans QR → validates signature → registers vaccination → (mints NFT on Soroban contract via Express backend).
3. NFT token contains immutable attributes about the vaccine application.
4. Future validations can read on-chain: owner, attributes, history.

---

## 2. Soroban Smart Contract (Rust)

Main file: `contract/contracts/hello-world/src/lib.rs`

### 2.1. Objective

Minimalist NFT contract specialized in vaccination – each token represents an individual application, including sanitary metadata.

### 2.2. Persistent Storage

Symbolic keys (`Symbol`):

-   `admin` – Authorized address to issue NFTs.
-   `name` / `symbol` – Token collection metadata.
-   `next_id` – Incremental counter (u128) to generate new token IDs.
-   `owner:{id}` – Owner of each token.
-   `attrs:{id}` – Structured attributes (`VaccineAttrs`).

### 2.3. Attributes Structure

```rust
pub struct VaccineAttrs {
  pub name: String,
  pub batch: String,
  pub exp_date: u64,    // expiration timestamp of batch or vaccine validity
  pub taken_date: u64,  // application timestamp
}
```

### 2.4. Main Functions

| Function                                                         | Description                             | Restriction                           |
| ---------------------------------------------------------------- | --------------------------------------- | ------------------------------------- |
| `initialize(admin, name, symbol)`                                | Configures contract on first execution. | Can only be called once.              |
| `mint_with_attrs(to, vaccine_name, batch, exp_date, taken_date)` | Generates new NFT + saves attributes.   | Requires `admin.require_auth()`       |
| `get_attrs(token_id)`                                            | Returns stored attributes.              | Fails if not found.                   |
| `owner_of(token_id)`                                             | Returns owner's `Address`.              | —                                     |
| `update_attrs(caller, token_id, ...)`                            | Allows updating attributes.             | Only owner (`caller.require_auth()`). |
| `transfer(from, to, token_id)`                                   | Transfers ownership.                    | `from` must be owner.                 |

### 2.5. Errors

`TokenNotFound`, `NotOwner`, `NotAdmin` – thrown via `panic_with_error!`.

### 2.6. Security & Considerations

-   Admin hard-coded via initial storage – ideal: allow rotation (future `set_admin` function).
-   No explicit log events (Soroban can use events for off-chain indexing – recommended to add).
-   Attribute update by owner: allows mutability (correction cases). If regulatory immutability is desired, create `mint_immutable` variant.
-   No approval/delegation support (could be added for clinical custody).

### 2.7. Future Extensions

-   Events: `event_mint`, `event_transfer`, `event_update` for indexers.
-   Revocation control (e.g., invalid token).
-   Additional fields: manufacturer, dose (1/2/3), professional, document hash.
-   Integration with DID / SIOP verifiers.

---

## 3. Express Backend (TypeScript)

Path: `backend-express-ts/`

### 3.1. Objective

Serve as a secure orchestrator for Soroban contract calls (mint) and mediate off-chain business logic (validations, local persistence in SQLite/file – inferred) before exposing endpoints to frontends.

### 3.2. Technologies

-   `express` – REST API.
-   `@stellar/stellar-sdk` – Construction and sending of Soroban/Stellar transactions.
-   `tsx` + `typescript` – Fast DX (watch mode).
-   `dotenv` – Configuration of keys and contract IDs.

### 3.3. Blockchain Service: `stellar_service.ts`

Key points:

-   Uses `Horizon.Server` pointed to `settings.STELLAR_NETWORK_URL` (Testnet).
-   Retrieves admin account (`CONTRACT_ADMIN_SECRET_KEY`).
-   Builds transaction calling `mint_with_attrs` method on contract via `Contract.call`.
-   Parameters serialized with `nativeToScVal` for Soroban types (string / u64 / Address).
-   Signs transaction with admin key and sends.
-   (Future TODO) Parse events to extract `token_id` from result (`scValToNative` in return / events).

### 3.4. Suggested Hardening

-   Validate `exp_date` limits and temporal coherence.
-   Rate limiting / auth (currently absent).
-   Robust `token_id` extraction via XDR event reading.
-   Dry-run mode to estimate costs (Soroban simulation before `submitTransaction`).

### 3.5. Endpoints (Inferred)

`/api/v1/...` routes for `user` and `vaccine` (not detailed). Recommended to add OpenAPI documentation in the future.

---

## 4. Admin Web (React + Vite)

Path: `admin_web/`

### 4.1. Objective

Interface for healthcare professionals to perform:

-   Login (simulated).
-   Reading patient's signed QR identity.
-   Ed25519 signature validation.
-   Application registration (generates certificate QR) – future: triggers mint on backend.

### 4.2. Technologies & UI

-   Build: Vite (`@vitejs/plugin-react-swc`).
-   UI Libs: Radix UI primitives, Tailwind Merge, custom components (`Button`, `Card` etc.).
-   QR: `qr-scanner`, `qrcode.react`.
-   Webcam / video: `react-webcam`.
-   Simple local state (React hooks) – no global store yet.

### 4.3. Validation Module (`src/utils/stellar-validation.ts`)

Functions:

-   `validateQRCodeStructure` – sanity check JSON.
-   `validateQRCodeSignature` – tests multiple serialization formats → brute-force friendly for key ordering differences until standardization.
-   Uses `Keypair.fromPublicKey` and `verify(dataBuffer, signatureBuffer)` (JS SDK).

Recommended improvement: Canonical JSON normalization at emitter (already done in Flutter) and try only that format here → reduces ambiguous surface.

### 4.4. QR Flow

1. Patient presents QR (payload `{data:{name,cpf,publicKey}, signature}` Base64).
2. Scanner decodes, validates structure → validates signature.
3. If valid, fills vaccination registration form.
4. Upon completion, generates certificate QR (currently placeholder). Next step: POST to backend calling mint.

### 4.5. Next Steps for Admin Frontend

-   Integrate `/vaccines/mint` endpoint that delegates to `createVacToken`.
-   Display transaction hash + token_id.
-   Local cache/history of scanned applications.

---

## 5. User App (Flutter)

Path: `user/frontend/`

### 5.1. Objective

Provide basic self-sovereign identity + vaccination records wallet. Generates keys locally without exposing seed.

### 5.2. Technologies

-   `stellar_flutter_sdk` – Key generation and Ed25519 signing.
-   `flutter_secure_storage` – Secure local storage.
-   `mobile_scanner` – QR reading.
-   `qr_flutter` – Signed identity QR rendering.
-   `local_auth` + (potential) biometrics for future gating.

### 5.3. Cryptography / Identity

`StellarKeyManager` (`utils/stellar.dart`):

-   Generates/persists key pair (seed + public key) in secure storage.
-   Supports rotation, controlled export.

`StellarCrypto` (`services/stellar_crypto.dart`):

-   Normalizes deterministic JSON (sorts keys) → signs → builds payload `{ data, signature }`.
-   Verification also possible (used in clinical scanner).

### 5.4. Identity QR Generation

Screen `user_qrcode.dart`:

-   Builds map `{ name, cpf, publicKey }`.
-   Signs via `signMapAsJson`.
-   Displays QR containing full signable JSON.

### 5.5. Scanner (`scan_health_center.dart`)

-   Reads codes and detects signed format.
-   Verifies signature locally (no backend) – privacy by design.
-   Confirms with user before approving data.

### 5.6. Possible Evolution

-   Register on-chain consent transaction (user signature confirming application).
-   Sync real NFT tokens and display them (requires Soroban RPC reading).
-   Support for multiple profiles (dependents).

---

## 6. End-to-End Blockchain Flows

### 6.1. Vaccination Issuance (Mint)

1. Admin Web validates identity → sends POST to backend with `{publicKey, vaccine_name, batch, exp_date, taken_date}`.
2. Backend builds Soroban transaction `mint_with_attrs` (admin signs) → submits.
3. Response returns `tx_hash` and (future) `token_id`.
4. User app can query `owner_of(token_id)` and `get_attrs(token_id)`.

### 6.2. Off-chain Identity Verification

-   Signed QR ensures integrity without needing on-chain (cost/latency savings).

### 6.3. Attribute Updates

-   `update_attrs` function allows corrections. Consider history tracking via events (audit).

### 6.4. Transfer

-   Possible to migrate token to another account (e.g., wallet interoperability). Normally vaccination tokens are non-transferable → consider soulbound restriction in the future.

---

## 7. Technologies and Justifications

| Category              | Technology                                   | Reason                                                            | Alternatives                       |
| --------------------- | -------------------------------------------- | ----------------------------------------------------------------- | ---------------------------------- |
| Smart Contract        | Soroban (Stellar)                            | Deterministic execution, WASM support, native Stellar integration | EVM (Polygon), Hyperledger Fabric  |
| Contract Language     | Rust                                         | Memory safety, robust ecosystem, direct Soroban support           | Go, AssemblyScript                 |
| Backend               | Express + TS                                 | Fast prototyping, typings and ecosystem                           | Fastify, NestJS                    |
| Blockchain SDK (Node) | `@stellar/stellar-sdk`                       | Signing and building Soroban transactions                         | Direct Soroban RPC + low-level XDR |
| Web Admin             | React + Vite                                 | Fast DX, UI ecosystem (Radix)                                     | Next.js, SvelteKit                 |
| QR & Web Signatures   | `@stellar/stellar-sdk` + custom verification | Reuse of reliable Ed25519 libs                                    | libsodium.js                       |
| Mobile                | Flutter                                      | Consistent cross-platform UI                                      | React Native, Kotlin Multiplatform |
| Mobile Crypto         | `stellar_flutter_sdk`                        | Compatible with Stellar format                                    | pointycastle                       |
| Secure Storage        | `flutter_secure_storage`                     | Seed protection                                                   | Hive + manual encryption           |
| Scanner               | `mobile_scanner`                             | Performance + cross-platform                                      | qr_code_scanner                    |

---

## 8. Development Guide

### 8.1. Prerequisites

-   Node 18+, Rust + cargo, Flutter SDK, Soroban CLI (`soroban`), Docker (optional for future indexer).

### 8.2. Contract

```bash
# Build release
cd contract
cargo build --target wasm32-unknown-unknown --release
# Deploy & invoke (example – IDs vary)
soroban contract deploy --wasm target/wasm32-unknown-unknown/release/hello_world.wasm --network testnet --source admin
soroban contract invoke --id <CONTRACT_ID> --network testnet --source admin -- initialize --admin admin --name "VaccineNFT" --symbol "VNFT"
```

### 8.3. Express Backend

```bash
cd backend-express-ts
cp .env.example .env   # (create if necessary)
npm install
npm run dev
```

Expected variables:

-   `STELLAR_NETWORK_URL` (e.g., https://horizon-testnet.stellar.org)
-   `CONTRACT_ADMIN_SECRET_KEY`
-   `VACCINE_CONTRACT_ID`

### 8.4. Admin Web

```bash
cd admin_web
npm install
npm run dev
```

### 8.5. Flutter App

```bash
cd user/frontend
flutter pub get
flutter run
```

For testnet funding (optional) call `friendBotIfNeeded()` after generating account.

---

## 9. Security & Best Practices

-   Seeds never leave the user's device (only local signing).
-   Signatures use canonical JSON at emitter – reduce ambiguity in verifier.
-   Recommended to add PIN/biometrics before displaying seed.
-   Admin key (backend) must be protected (.env + secret manager in production).
-   Validate input before building transactions to prevent abuse (batch size, dates).
-   Add structured logs and transaction failure monitoring.

Potential threats:

-   QR cloning (replay): Mitigate by including short nonce/timestamp and expiration.
-   Abusive minting: Rate limit + auth for issuance endpoint.
-   Malicious attribute updates: consider immutability or version logging.

---

## 10. Future Roadmap

1. Programmatic `token_id` extraction post-mint via event analysis.
2. Off-chain indexer (subscribes to events -> fast query API).
3. Revocation proof / early expiration.
4. Soulbound mode (block `transfer`).
5. Dual consent: user signs intent off-chain → backend includes hash in transaction.
6. Support for multiple networks (testnet / futurenet / mainnet toggle).
7. Integration with verifiable credentials standards (VC + JSON-LD).
8. Analytical dashboard (vaccination metrics by batch / region).
9. Integration with external wallet (e.g., Freighter) for admin.
10. Exportable cryptographic audit (proof bundles).

---

## 11. Quick Glossary

-   **Soroban**: Stellar's smart contract platform.
-   **Horizon**: API for accessing Stellar accounts/ledger (pre-Soroban). For full Soroban use dedicated RPC.
-   **Address**: Representation of account (ed25519) or contract.
-   **Parameterized NFT**: Non-fungible token with custom persisted attributes.
-   **FriendBot**: Service that funds testnet accounts with initial Lumens.

---

## 12. Simplified Text Diagram

```
[Flutter App]
  - Generates keys
  - Signs identity  --->  [QR Code]  --->  [Admin Web Scanner]
                                                | validates signature
                                                v
                                       (POST /mint) -> [Express Backend] --tx--> [Soroban Contract]
                                                                    tx_hash/token_id
                                                ^                                        |
                                                |---------------- on-chain query -------|
```

---

## 13. Request Coverage Check

-   Describe app integration: ✔
-   Blockchain emphasis (contract + signatures + mint flow): ✔
-   Detailed technologies and justifications: ✔
-   End-to-end flows: ✔
-   Roadmap and security: ✔

---

## 14. Recommended Immediate Next Steps

-   Implement definitive REST endpoint: `POST /api/v1/vaccines/mint`.
-   In Admin Web, call endpoint after form confirmation.
-   Add return parsing to display `token_id`.
-   Add events to contract and indexing script.

---

## 15. Usage Instructions

### 15.1. Initial Setup

1. **Clone the repository:**

    ```bash
    git clone https://github.com/rafael-tagliamento/hackMeridian.git
    cd hackMeridian
    ```

2. **Configure Stellar environment:**

    - Create an account on Stellar testnet.
    - Fund the account using FriendBot: https://laboratory.stellar.org/#account-creator?network=test
    - Note the secret and public keys.

3. **Deploy Soroban Contract:**
    - Install Soroban CLI: `cargo install soroban-cli`
    - Navigate to `contract/` and execute:
        ```bash
        cargo build --target wasm32-unknown-unknown --release
        soroban contract deploy --wasm target/wasm32-unknown-unknown/release/hello_world.wasm --network testnet --source <your_account>
        ```
    - Initialize the contract with the command provided in the development guide.

### 15.2. Running Components

-   **Express Backend:** `cd backend-express-ts && npm install && npm run dev`
-   **Admin Web:** `cd admin_web && npm install && npm run dev`
-   **Flutter App:** `cd user/frontend && flutter pub get && flutter run`

### 15.3. Usage Flow

1. Open the Flutter app and generate an identity (QR Code).
2. In Admin Web, log in and scan the patient's QR.
3. Register the vaccination and generate the certificate.
4. (Future) The backend will mint the NFT on the blockchain.

---

## 16. Hackathon Details

This project was developed during the **Hackathon Meridian**, held on **September 15 and 16, 2025** in **Rio de Janeiro**. The event brought together students and professionals to create innovative solutions in blockchain and health.

ImmuneChain was conceived as a solution for secure and immutable verification of vaccination records, using Stellar/Soroban technology to ensure transparency and trust.

---

## 17. Contributors

-   **Rafael Tagliamento** - Frontend development and web development, direction and video editing.
-   **Miguel Ramos** - Backend development, blockchain integration, mobile and web frontend development.
-   **Bruna Albuquerque** - Mobile frontend development, video editing.
-   **Matheus Veiga** - Frontend development, graphic design.
-   **Vinicius Maciel** - Frontend development, business feasibility research.

Special thanks to the mentors and organizers of Hackathon Meridian.

---

_End of document._
