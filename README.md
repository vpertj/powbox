# PwBox - Secure Password Manager

PwBox is a secure, open-source, cross-platform password manager that helps you safely store and manage all of your passwords.

## Features

- 🔒 **Military-grade encryption** - Protects your data with Argon2 and AES-256-GCM encryption
- 🌐 **Cross-platform support** - Available on Windows, macOS, and Linux
- 📱 **Intuitive interface** - A modern, easy-to-use user interface
- 🏠 **Group management** - Organize your password entries by category
- 🔍 **Powerful search** - Quickly find your password entries
- 🗃️ **Attachment support** - Attach files to password entries
- 🔄 **Automatic backup** - Automatically backs up your database to prevent data loss
- 🗑️ **Trash bin** - Recover accidentally deleted entries
- 🔐 **Two-factor authentication** - An extra layer of security
- 🌓 **Dark/light themes** - Pick the interface theme that suits your preference
- 🌍 **Multilingual support** - Interface available in both Chinese and English

## Getting Started

### System Requirements

- Windows 10 or later
- macOS 10.15 or later
- Linux (Ubuntu 20.04 or similar distributions)

### Installation

1. Download the installer for your system from the [releases page](https://github.com/your-username/pwbox/releases)
2. Run the installer and follow the prompts to complete the installation
3. Launch PwBox and create your first password database

### Development

If you would like to build PwBox from source:

#### Prerequisites

- Flutter SDK 3.0 or later
- Dart SDK 2.17 or later

#### Build Steps

```bash
# Clone the repository
git clone https://github.com/your-username/pwbox.git
cd pwbox

# Fetch dependencies
flutter pub get

# Run the app
flutter run

# Build a release version
flutter build windows  # Windows
flutter build macos    # macOS
flutter build linux    # Linux
```

## Usage

1. **Create a database** - On first launch, choose to create a new database and set a master password
2. **Add entries** - Click the "+" button to add a new password entry
3. **Organize groups** - Create groups to categorize and manage your passwords
4. **Search entries** - Use the search box at the top to quickly find passwords
5. **Generate passwords** - Use the built-in password generator to create strong passwords
6. **Enable backup** - Turn on automatic backup in settings to protect your data

## Security

- All data is encrypted locally with Argon2 and AES-256-GCM
- The master password is never stored on your device
- Database files are encrypted, so they cannot be read even with physical access
- Two-factor authentication provides an additional layer of security

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Contact

Project link: [https://github.com/your-username/pwbox](https://github.com/your-username/pwbox)

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Argon2](https://github.com/P-H-C/phc-winner-argon2)
- [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)
