# Vaccine Verification API (Express + TypeScript)

This is the backend API for the ImmuneChain ecosystem, built with Express.js and TypeScript. It handles vaccine token creation on the Stellar blockchain via Soroban smart contracts.

## Features

-   RESTful API for vaccine token management
-   Integration with Stellar Soroban contracts using `@stellar/stellar-sdk`
-   TypeScript for type safety
-   Environment-based configuration

## Prerequisites

-   Node.js 18+
-   npm or yarn
-   Stellar testnet account with funds (for contract interactions)

## Installation

1. Clone the repository and navigate to the project:

    ```bash
    cd backend-express-ts
    ```

2. Install dependencies:

    ```bash
    npm install
    ```

3. Create a `.env` file based on `.env.example`:

    ```bash
    cp .env.example .env
    ```

    Configure the following variables:

    - `STELLAR_NETWORK_URL`: Stellar network URL (e.g., https://horizon-testnet.stellar.org)
    - `CONTRACT_ADMIN_SECRET_KEY`: Secret key for the contract admin account
    - `VACCINE_CONTRACT_ID`: Deployed Soroban contract ID
    - `PORT`: Server port (default: 3000)

## Usage

### Development

```bash
npm run dev
```

### Production

```bash
npm run build
npm start
```

## API Endpoints

-   `GET /`: Welcome message
-   `POST /api/v1/vaccines/mint`: Create a new vaccine token on the blockchain

## Project Structure

-   `src/index.ts`: Main application entry point
-   `src/routes/`: API route handlers
-   `src/services/`: Business logic, including Stellar integration
-   `src/core/`: Configuration and utilities

## Dependencies

-   `@stellar/stellar-sdk`: For Stellar blockchain interactions
-   `express`: Web framework
-   `dotenv`: Environment variable management
-   `typescript`: TypeScript compiler

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

ISC
