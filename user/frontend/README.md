# ImmuneChain User App

A Flutter application for users to manage their vaccination records and generate verifiable identity QR codes using Stellar blockchain technology.

## Features

-   Generate and store Stellar key pairs locally
-   Create signed QR codes for identity verification
-   Scan and verify healthcare provider QR codes
-   View vaccination history
-   Secure storage using flutter_secure_storage

## Prerequisites

-   Flutter SDK (3.4.0 or higher)
-   Dart SDK
-   Android Studio or Xcode for mobile development

## Installation

1. Navigate to the project directory:

    ```bash
    cd user/frontend
    ```

2. Install dependencies:
    ```bash
    flutter pub get
    ```

## Usage

### Run on Android

```bash
flutter run
```

### Run on iOS (macOS only)

```bash
flutter run
```

### Build for Production

```bash
flutter build apk  # For Android
flutter build ios  # For iOS
```

## Project Structure

-   `lib/main.dart`: Application entry point
-   `lib/models/`: Data models (User, Vaccine)
-   `lib/screens/`: UI screens (QR code display, scanner, etc.)
-   `lib/services/`: Business logic (Stellar crypto, key management)
-   `lib/utils/`: Utility functions
-   `lib/theme/`: Theme and styling

## Key Features

-   **Stellar Key Management**: Generates and securely stores Ed25519 key pairs
-   **QR Code Generation**: Creates signed JSON payloads for identity
-   **QR Code Scanning**: Verifies signatures from healthcare providers
-   **Vaccination Records**: Displays user vaccination history

## Technologies

-   **Flutter**: Cross-platform UI framework
-   **stellar_flutter_sdk**: Stellar blockchain integration
-   **mobile_scanner**: QR code scanning
-   **qr_flutter**: QR code generation
-   **flutter_secure_storage**: Secure local storage
-   **crypto**: Cryptographic functions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

ISC
