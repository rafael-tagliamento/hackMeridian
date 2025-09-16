# ImmuneChain Admin Web App

A React-based web application for healthcare professionals to manage vaccination records and verify patient identities using QR codes and Stellar blockchain integration.

## Features

-   User authentication for healthcare professionals
-   QR code scanning for patient identity verification
-   Vaccine record registration
-   Integration with Stellar blockchain for secure data handling
-   Responsive UI built with Radix UI components

## Prerequisites

-   Node.js 18+
-   npm or yarn

## Installation

1. Navigate to the project directory:

    ```bash
    cd admin_web
    ```

2. Install dependencies:
    ```bash
    npm install
    ```

## Usage

### Development

```bash
npm run dev
```

### Build for Production

```bash
npm run build
```

## Project Structure

-   `src/App.tsx`: Main application component
-   `src/components/`: Reusable UI components
-   `src/utils/`: Utility functions, including Stellar validation
-   `src/assets/`: Static assets like logos

## Key Components

-   **QRScanner**: Scans patient QR codes
-   **WebcamScanner**: Alternative scanning using webcam
-   **VaccinationLists**: Displays patient vaccination history
-   **MaterialSelect**: Custom select components

## Technologies

-   **React**: Frontend framework
-   **Vite**: Build tool and dev server
-   **Radix UI**: Accessible UI components
-   **Tailwind CSS**: Utility-first CSS framework
-   **@stellar/stellar-sdk**: Stellar blockchain integration
-   **qr-scanner**: QR code scanning library

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

ISC
