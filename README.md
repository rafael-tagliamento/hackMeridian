# ImmuneChain Architecture & Blockchain Integration

<<<<<<< HEAD
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
=======
> Versão: 1.0 – Foco em: Smart Contract Soroban (Rust), Backend Express (TypeScript), Admin Web (React + Vite), App Usuário (Flutter). **Backend Python ignorado conforme solicitado.**

---

## 1. Visão Geral do Ecossistema

ImmuneChain é um ecossistema multi-plataforma para emissão, distribuição e verificação de **NFTs de vacinação** e identidades verificáveis, utilizando **Soroban/Stellar** como camada de confiança.

Componentes focados:

-   **Smart Contract (Rust + Soroban)** – Emissão e gestão de NFTs de vacina com atributos (nome, lote, validade, data de aplicação).
-   **Backend Express TypeScript** – API que orquestra mint no contrato via `@stellar/stellar-sdk` e expõe endpoints REST.
-   **Admin Web (React)** – Interface para profissionais de saúde: escaneia identidade do paciente via QR assinado e registra vacinação (futuro: chama mint NFT).
-   **App Usuário (Flutter)** – Gera e assina identidade digital (QR Code) com chave Ed25519 local, permite ver carteira de vacinas e verificar registros.

Fluxo macro (MVP atual + intenção):

1. Usuário abre app Flutter → gera par de chaves Stellar localmente → QR Code de identidade (JSON + assinatura Ed25519).
2. Profissional (Admin Web) escaneia QR → valida assinatura → registra vacinação → (mint NFT no contrato Soroban via backend Express).
3. Token NFT contém atributos imutáveis sobre a aplicação da vacina.
4. Futuras validações podem ler on-chain: proprietário, atributos, histórico.

---

## 2. Smart Contract Soroban (Rust)

Arquivo principal: `contract/contracts/hello-world/src/lib.rs`

### 2.1. Objetivo

Contrato NFT minimalista especializado em vacinação – cada token representa uma aplicação individual, incluindo metadados sanitários.

### 2.2. Armazenamento Persistente

Chaves simbólicas (`Symbol`):

-   `admin` – Endereço autorizado a emitir NFTs.
-   `name` / `symbol` – Metadados do token collection.
-   `next_id` – Contador incremental (u128) para gerar novos token IDs.
-   `owner:{id}` – Dono de cada token.
-   `attrs:{id}` – Atributos estruturados (`VaccineAttrs`).

### 2.3. Estrutura de Atributos
>>>>>>> 0a13f04 (readmes)

```rust
pub struct VaccineAttrs {
  pub name: String,
  pub batch: String,
<<<<<<< HEAD
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
=======
  pub exp_date: u64,    // timestamp de expiração do lote ou validade do imunizante
  pub taken_date: u64,  // timestamp da aplicação
}
```

### 2.4. Funções Principais

| Função                                                           | Descrição                                | Restrição                              |
| ---------------------------------------------------------------- | ---------------------------------------- | -------------------------------------- |
| `initialize(admin, name, symbol)`                                | Configura contrato na primeira execução. | Só pode ser chamada uma vez.           |
| `mint_with_attrs(to, vaccine_name, batch, exp_date, taken_date)` | Gera novo NFT + salva atributos.         | Requer `admin.require_auth()`          |
| `get_attrs(token_id)`                                            | Retorna atributos armazenados.           | Fails se não existir.                  |
| `owner_of(token_id)`                                             | Retorna `Address` do dono.               | —                                      |
| `update_attrs(caller, token_id, ...)`                            | Permite atualizar atributos.             | Apenas dono (`caller.require_auth()`). |
| `transfer(from, to, token_id)`                                   | Transfere propriedade.                   | `from` deve ser owner.                 |

### 2.5. Erros

`TokenNotFound`, `NotOwner`, `NotAdmin` – lançados via `panic_with_error!`.

### 2.6. Segurança & Considerações

-   Admin hard-coded via armazenamento inicial – ideal: permitir rotação (função `set_admin` futura).
-   Não há eventos explícitos de log (Soroban pode usar eventos para indexação off-chain – recomendável adicionar).
-   Atualização de atributos por owner: permite mutabilidade (casos de correção). Se quiser imutabilidade regulatória, criar variante `mint_immutable`.
-   Sem suporte a aprovação/delegação (poderia ser adicionado para custódia clínica).

### 2.7. Extensões Futuras

-   Eventos: `event_mint`, `event_transfer`, `event_update` para indexers.
-   Controle de revogação (ex: token inválido).
-   Campos adicionais: fabricante, dose (1/2/3), profissional, hash de documento.
-   Integração com verificadores de DID / SIOP.

---

## 3. Backend Express (TypeScript)

Path: `backend-express-ts/`

### 3.1. Objetivo

Servir como orquestrador seguro para chamadas ao contrato Soroban (mint) e mediar lógica de negócio off-chain (validações, persistência local em SQLite/arquivo – inferido) antes de expor endpoints para frontends.

### 3.2. Tecnologias

-   `express` – REST API.
-   `@stellar/stellar-sdk` – Construção e envio de transações Soroban/Stellar.
-   `tsx` + `typescript` – DX rápida (watch mode).
-   `dotenv` – Configuração de chaves e IDs de contrato.

### 3.3. Serviço Blockchain: `stellar_service.ts`

Pontos-chave:

-   Usa `Horizon.Server` apontado para `settings.STELLAR_NETWORK_URL` (Testnet).
-   Recupera conta admin (`CONTRACT_ADMIN_SECRET_KEY`).
-   Constrói transação chamando método `mint_with_attrs` do contrato via `Contract.call`.
-   Parâmetros serializados com `nativeToScVal` para tipos Soroban (string / u64 / Address).
-   Assina transação com chave admin e envia.
-   (TODO futuro) Parsear eventos para extrair `token_id` do resultado (`scValToNative` em retorno / events).

### 3.4. Hardening Sugerido

-   Validar limites de `exp_date` e coerência temporal.
-   Rate limiting / auth (atualmente ausente).
-   Extração robusta do `token_id` via leitura de eventos XDR.
-   Modo dry-run para estimar custos (Soroban simulation antes do `submitTransaction`).

### 3.5. Endpoints (Inferidos)

`/api/v1/...` rotas de `user` e `vaccine` (não inspecionadas detalhadamente). Recomenda-se adicionar documentação OpenAPI futura.
>>>>>>> 0a13f04 (readmes)

---

## 4. Admin Web (React + Vite)

Path: `admin_web/`

<<<<<<< HEAD
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
=======
### 4.1. Objetivo

Interface para profissionais de saúde realizarem:

-   Login (simulado).
-   Leitura de QR do paciente (identidade assinada).
-   Validação de assinatura Ed25519.
-   Registro da aplicação (gera QR de atestado) – futuramente aciona mint no backend.

### 4.2. Tecnologias & UI

-   Build: Vite (`@vitejs/plugin-react-swc`).
-   Libs UI: Radix UI primitives, Tailwind Merge, componentes custom (`Button`, `Card` etc.).
-   QR: `qr-scanner`, `qrcode.react`.
-   Webcam / vídeo: `react-webcam`.
-   Estado local simples (React hooks) – sem global store ainda.

### 4.3. Módulo de Validação (`src/utils/stellar-validation.ts`)

Funções:

-   `validateQRCodeStructure` – sanity check JSON.
-   `validateQRCodeSignature` – testa vários formatos de serialização → brute-force amigável para diferenças de ordenação de chaves até padronização.
-   Usa `Keypair.fromPublicKey` e `verify(dataBuffer, signatureBuffer)` (SDK JS).

Melhoria recomendada: Normalizar JSON canônico no emissor (já feito no Flutter) e aqui tentar apenas esse formato → reduz superfície ambígua.

### 4.4. Fluxo QR

1. Paciente apresenta QR (payload `{data:{name,cpf,publicKey}, signature}` Base64).
2. Scanner decodifica, valida estrutura → valida assinatura.
3. Se válido, preenche formulário de registro de vacina.
4. Ao finalizar, gera QR de atestado (atualmente placeholder). Próximo passo: POST para backend chamando mint.

### 4.5. Próximos Passos Front Admin

-   Integrar endpoint `/vaccines/mint` que delega para `createVacToken`.
-   Exibir hash transação + token_id.
-   Cache local/histórico de aplicações escaneadas.

---

## 5. App Usuário (Flutter)

Path: `user/frontend/`

### 5.1. Objetivo

Fornecer identidade auto-soberana básica + carteira de registros de vacinação. Gera chaves localmente sem expor seed.

### 5.2. Tecnologias

-   `stellar_flutter_sdk` – Geração de chaves e assinatura Ed25519.
-   `flutter_secure_storage` – Armazenamento seguro de seed.
-   `mobile_scanner` – Leitura de QRs.
-   `qr_flutter` – Renderização de QR da identidade assinada.
-   `local_auth` + (potencial) biometria para gating futuro.

### 5.3. Criptografia / Identidade

`StellarKeyManager` (`utils/stellar.dart`):

-   Gera/par persistente (seed + public key) em storage seguro.
-   Suporta rotação, exportação controlada.

`StellarCrypto` (`services/stellar_crypto.dart`):

-   Normaliza JSON determinístico (ordena chaves) → assina → monta payload `{ data, signature }`.
-   Verificação também possível (usada no scanner clínico).

### 5.4. Geração de QR de Identidade

Tela `user_qrcode.dart`:

-   Monta mapa `{ name, cpf, publicKey }`.
-   Assina via `signMapAsJson`.
-   Exibe QR contendo JSON completo assinável.

### 5.5. Scanner (`scan_health_center.dart`)

-   Lê códigos e detecta formato assinado.
-   Verifica assinatura localmente (sem backend) – privacidade by design.
-   Confirma com usuário antes de aprovar dados.

### 5.6. Possível Evolução

-   Registrar transação de consentimento on-chain (assinatura do usuário confirmando aplicação).
-   Sincronizar tokens NFT reais e exibi-los (requere leitura do contrato via RPC Soroban).
-   Suporte a múltiplos perfis (dependentes).

---

## 6. Fluxos Blockchain Ponta-a-Ponta

### 6.1. Emissão (Mint) de Vacina

1. Admin Web valida identidade → envia POST ao backend com `{publicKey, vaccine_name, batch, exp_date, taken_date}`.
2. Backend monta transação Soroban `mint_with_attrs` (admin assina) → submete.
3. Resposta retorna `tx_hash` e (futuramente) `token_id`.
4. App usuário pode consultar `owner_of(token_id)` e `get_attrs(token_id)`.

### 6.2. Verificação Off-chain (Identidade)

-   QR assinado garante integridade sem precisar ir on-chain (economia de custo / latência).

### 6.3. Atualização Atributos

-   Função `update_attrs` permite correções. Considerar rastreamento de histórico via eventos (auditoria).

### 6.4. Transferência

-   Possível migrar token para outra conta (ex: interoperabilidade entre carteiras). Normalmente tokens de vacinação são não-transferíveis → considerar restrição (soulbound) futura.

---

## 7. Tecnologias e Justificativas

| Categoria             | Tecnologia                                  | Motivo                                                             | Alternativas                            |
| --------------------- | ------------------------------------------- | ------------------------------------------------------------------ | --------------------------------------- |
| Smart Contract        | Soroban (Stellar)                           | Execução determinística, suporte a WASM, integração nativa Stellar | EVM (Polygon), Hyperledger Fabric       |
| Linguagem contrato    | Rust                                        | Segurança de memória, ecosistema robusto, suporte direto Soroban   | Go, AssemblyScript                      |
| Backend               | Express + TS                                | Rapidez prototipagem, typings e ecosistema                         | Fastify, NestJS                         |
| SDK Blockchain (Node) | `@stellar/stellar-sdk`                      | Assinatura e construção de transações Soroban                      | Soroban RPC diretamente + low-level XDR |
| Web Admin             | React + Vite                                | DX rápida, ecosistema UI (Radix)                                   | Next.js, SvelteKit                      |
| QR & Assinaturas Web  | `@stellar/stellar-sdk` + custom verificação | Reuso de libs confiáveis Ed25519                                   | libsodium.js                            |
| Mobile                | Flutter                                     | UI multi-plataforma consistente                                    | React Native, Kotlin Multiplatform      |
| Cripto Mobile         | `stellar_flutter_sdk`                       | Compatível com formato Stellar                                     | pointycastle                            |
| Storage Seguro        | `flutter_secure_storage`                    | Proteção seed                                                      | Hive + criptografia manual              |
| Scanner               | `mobile_scanner`                            | Performance + multiplataforma                                      | qr_code_scanner                         |

---

## 8. Guia de Desenvolvimento

### 8.1. Pré-requisitos

-   Node 18+, Rust + cargo, Flutter SDK, Soroban CLI (`soroban`), Docker (opcional para futuro indexer).

### 8.2. Contrato
>>>>>>> 0a13f04 (readmes)

```bash
# Build release
cd contract
cargo build --target wasm32-unknown-unknown --release
<<<<<<< HEAD
# Deploy & invoke (example – IDs vary)
=======
# Deploy & invoke (exemplo – IDs variam)
>>>>>>> 0a13f04 (readmes)
soroban contract deploy --wasm target/wasm32-unknown-unknown/release/hello_world.wasm --network testnet --source admin
soroban contract invoke --id <CONTRACT_ID> --network testnet --source admin -- initialize --admin admin --name "VaccineNFT" --symbol "VNFT"
```

<<<<<<< HEAD
### 8.3. Express Backend

```bash
cd backend-express-ts
cp .env.example .env   # (create if necessary)
=======
### 8.3. Backend Express

```bash
cd backend-express-ts
cp .env.example .env   # (criar se necessário)
>>>>>>> 0a13f04 (readmes)
npm install
npm run dev
```

<<<<<<< HEAD
Expected variables:

-   `STELLAR_NETWORK_URL` (e.g., https://horizon-testnet.stellar.org)
=======
Variáveis esperadas:

-   `STELLAR_NETWORK_URL` (ex: https://horizon-testnet.stellar.org)
>>>>>>> 0a13f04 (readmes)
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

<<<<<<< HEAD
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
=======
Para testnet funding (opcional) chamar `friendBotIfNeeded()` após gerar a conta.

---

## 9. Segurança & Boas Práticas

-   Seeds nunca saem do dispositivo do usuário (somente assinatura local).
-   Assinaturas usam JSON canônico no emissor – reduzir ambiguidade no verificador.
-   Recomendado adicionar pin / biometria antes de exibir seed.
-   Admin key (backend) deve ser protegida (.env + secret manager em produção).
-   Validar input antes de construir transações para evitar abuso (batch size, datas).
-   Adicionar logs estruturados e monitoramento de falhas de transação.

Ameaças potenciais:

-   Clonagem de QR (replay): Mitigar incluindo nonce/timestamp curto e expiração.
-   Mint abusivo: Rate limit + auth para endpoint de emissão.
-   Atualização maliciosa de atributos: considerar imutabilidade ou log de versão.

---

## 10. Roadmap Futuro

1. Extração programática de `token_id` pós-mint via análise de eventos.
2. Indexer off-chain (subscreve eventos -> API de consulta rápida).
3. Prova de revogação / expiração antecipada.
4. Soulbound mode (bloquear `transfer`).
5. Consentimento duplo: usuário assina intent off-chain → backend inclui hash na transação.
6. Suporte a múltiplas redes (testnet / futurenet / mainnet toggle).
7. Integração com padrões de credenciais verificáveis (VC + JSON-LD).
8. Dashboard analítico (métricas de vacinação por lote / região).
9. Integração com carteira externa (ex: Freighter) para admin.
10. Auditoria criptográfica exportável (proof bundles).

---

## 11. Glossário Rápido

-   **Soroban**: Plataforma de smart contracts da Stellar.
-   **Horizon**: API de acesso às contas/ledger Stellar (pré-Soroban). Para Soroban completo usa RPC dedicado.
-   **Address**: Representação de conta (ed25519) ou contrato.
-   **NFT Parametrizado**: Token não fungível com atributos customizados persistidos.
-   **FriendBot**: Serviço que financia contas na testnet com Lumens iniciais.

---

## 12. Diagrama (Texto Simplificado)

```
[Flutter App]
  - Gera chaves
  - Assina identidade  --->  [QR Code]  --->  [Admin Web Scanner]
                                                | valida assinatura
>>>>>>> 0a13f04 (readmes)
                                                v
                                       (POST /mint) -> [Express Backend] --tx--> [Soroban Contract]
                                                                    tx_hash/token_id
                                                ^                                        |
<<<<<<< HEAD
                                                |---------------- on-chain query -------|
=======
                                                |---------------- consulta on-chain -----|
>>>>>>> 0a13f04 (readmes)
```

---

<<<<<<< HEAD
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
=======
## 13. Check de Cobertura da Solicitação

-   Ignorar backend Python: ✔
-   Descrever integração entre apps: ✔
-   Ênfase blockchain (contrato + assinaturas + fluxo mint): ✔
-   Tecnologias detalhadas e justificadas: ✔
-   Fluxos ponta a ponta: ✔
-   Roadmap e segurança: ✔

---

## 14. Próximos Passos Imediatos Recomendados

-   Implementar endpoint REST definitivo: `POST /api/v1/vaccines/mint`.
-   No Admin Web, chamar endpoint após confirmação do formulário.
-   Adicionar parsing de retorno para exibir `token_id`.
-   Adicionar eventos no contrato e script de indexação.

---

## 15. Instruções de Uso

### 15.1. Configuração Inicial

1. **Clone o repositório:**
>>>>>>> 0a13f04 (readmes)

    ```bash
    git clone https://github.com/rafael-tagliamento/hackMeridian.git
    cd hackMeridian
    ```

<<<<<<< HEAD
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
=======
2. **Configure o ambiente Stellar:**

    - Crie uma conta na testnet Stellar.
    - Fund a conta usando o FriendBot: https://laboratory.stellar.org/#account-creator?network=test
    - Anote a chave secreta e pública.

3. **Deploy do Contrato Soroban:**
    - Instale Soroban CLI: `cargo install soroban-cli`
    - Navegue para `contract/` e execute:
        ```bash
        cargo build --target wasm32-unknown-unknown --release
        soroban contract deploy --wasm target/wasm32-unknown-unknown/release/hello_world.wasm --network testnet --source <sua_conta>
        ```
    - Inicialize o contrato com o comando fornecido no guia de desenvolvimento.

### 15.2. Executando os Componentes

-   **Backend Express:** `cd backend-express-ts && npm install && npm run dev`
-   **Admin Web:** `cd admin_web && npm install && npm run dev`
-   **App Flutter:** `cd user/frontend && flutter pub get && flutter run`

### 15.3. Fluxo de Uso

1. Abra o app Flutter e gere uma identidade (QR Code).
2. No Admin Web, faça login e escaneie o QR do paciente.
3. Registre a vacinação e gere o atestado.
4. (Futuro) O backend mintará o NFT na blockchain.

---

## 16. Detalhes do Hackathon

Este projeto foi desenvolvido durante o **Hackathon Meridian**, realizado nos dias **15 e 16 de setembro de 2025** no **Rio de Janeiro**. O evento reuniu estudantes e profissionais para criar soluções inovadoras em blockchain usando a tecnologia **Stellar**.

O ImmuneChain foi concebido como uma solução para verificação segura e imutável de registros de vacinação, utilizando a tecnologia Stellar/Soroban para garantir transparência e confiança.

---

## 17. Contribuidores

-   **Rafael Tagliamento** - Desenvolvimento frontend e desenvolvimento web, direção e montagem de vídeo.
-   **Miguel Ramos** - Desenvolvimento backend, integração blockchain, desenvolvimento frontend mobile e web.
-   **Bruna Albuquerque** - Desenvolvimento frontend mobile, edição de vídeo.
-   **Matheus Veiga** - Desenvolvimento frontend, design gráfico.
-   **Vinicius Maciel** - Desenvolvimento frontend, pesquisa de viabilidade de negócio.

Agradecimentos especiais aos mentores e organizadores do Hackathon Meridian.

---

_Fim do documento._
>>>>>>> 0a13f04 (readmes)
