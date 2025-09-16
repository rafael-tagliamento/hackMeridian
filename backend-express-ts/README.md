# Vaccine Verification API - Express.js + TypeScript

Uma API robusta e escalável- `POST /api/v1/create_vaccine` - Criar token NFT de vacinação via smart contract

-   **Corpo da requisição:**
    ```json
    {
    	"name": "Vacina COVID-19",
    	"description": "Primeira dose da vacina COVID-19",
    	"destination_public_key": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", // opcional
    	"batch": "LOTE-2024-001", // opcional
    	"exp_date": 1704067200000, // timestamp opcional
    	"taken_date": 1701388800000 // timestamp opcional
    }
    ```
-   **Resposta de sucesso:**
    ````json
    {
      "status": "success",
      "tx_hash": "hash_da_transacao",
      "destination_public_key": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
      "token_id": 1,
      "contract_id": "CA7QYNF7SOWQ3GLR2BGMZEHXAVIRZA4KVWLTJJFC7MGXUA74P7UJVSGZ"
    }
    ```rificação de tokens de vacinação na blockchain Stellar.
    ````

## Funcionalidades

-   ✅ Registro e consulta de usuários KYC
-   ✅ Emissão de tokens NFT de vacinação via smart contract Soroban
-   ✅ Verificação de tokens NFT na blockchain
-   ✅ API RESTful com Express.js
-   ✅ TypeScript para type safety
-   ✅ Integração com smart contract Rust personalizado

## Instalação

```bash
# Instalar dependências
npm install

# Copiar arquivo de ambiente
cp .env.example .env

# Configurar variáveis de ambiente no .env
```

## Smart Contract

Esta API integra com um smart contract NFT de vacinação desenvolvido em Rust usando Soroban. O contrato permite:

-   Mint de tokens NFT com atributos customizados (nome, lote, data de expiração, data de aplicação)
-   Consulta de atributos dos tokens
-   Transferência de tokens entre usuários
-   Verificação de propriedade

## Configuração

Edite o arquivo `.env` com suas chaves Stellar e o ID do contrato implantado:

```env
# Chaves Stellar
STELLAR_SECRET_KEY=sua_chave_secreta_aqui
STELLAR_PUBLIC_KEY=sua_chave_publica_aqui
STELLAR_NETWORK_URL=https://horizon-testnet.stellar.org

# ID do smart contract implantado
VACCINE_CONTRACT_ID=seu_contract_id_aqui

# Outras configurações
DB_URL=sqlite://./vaccine.db
PORT=3000
```

STELLAR_SECRET_KEY=sua_chave_secreta_aqui
STELLAR_PUBLIC_KEY=sua_chave_publica_aqui
STELLAR_NETWORK_URL=https://horizon-testnet.stellar.org
DB_URL=sqlite://./vaccine.db
PORT=3000

````

## Executar

```bash
# Desenvolvimento
npm run dev

# Desenvolvimento com debug
npm run dev:debug

# Produção
npm run build
npm start
````

## Endpoints

### Usuários

-   `POST /api/v1/users/register` - Registrar usuário KYC
-   `GET /api/v1/users/:wallet_address` - Consultar usuário por wallet

### Vacinas

-   `POST /api/v1/create_vaccine` - Criar token de vacinação
-   **Corpo da requisição:**
    ```json
    {
    	"name": "Vacina COVID-19",
    	"description": "Primeira dose da vacina COVID-19",
    	"destination_public_key": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" // opcional
    }
    ```
-   **Resposta de sucesso:**
    ```json
    {
    	"status": "success",
    	"tx_hash": "hash_da_transacao",
    	"destination_public_key": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    	"needs_additional_signature": false
    }
    ```
-   **Nota:** Se `destination_public_key` não for fornecida, uma chave aleatória será gerada automaticamente.

-   `GET /api/v1/verify_vaccine/:token_id` - Verificar token NFT

### Root

-   `GET /` - Mensagem de boas-vindas

## Estrutura do Projeto

```
src/
├── core/
│   └── config.ts          # Configurações da aplicação
├── models/
│   ├── user_kyc.ts        # Modelos de usuário KYC
│   └── vaccination_token.ts # Modelos de token de vacinação
├── routes/
│   ├── user.ts            # Rotas de usuário
│   └── vaccine.ts         # Rotas de vacinação
├── services/
│   ├── database_service.ts # Serviço de banco de dados
│   ├── stellar_service.ts  # Serviço Stellar blockchain
│   └── user_service.ts     # Serviço de usuário
└── index.ts               # Ponto de entrada da aplicação
```

## Tecnologias

-   **Express.js** - Framework web
-   **TypeScript** - Superset JavaScript com tipos
-   **Stellar SDK** - Integração com blockchain Stellar
-   **SQLite** - Banco de dados local
-   **TypeORM** - ORM para TypeScript
