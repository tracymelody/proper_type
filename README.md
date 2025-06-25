# ProperType - AI-Powered Text Improvement Tool

<div align="center">

![ProperType Logo](https://img.shields.io/badge/ProperType-AI%20Text%20Tool-blue?style=for-the-badge)
[![macOS](https://img.shields.io/badge/macOS-10.15+-brightgreen?style=for-the-badge&logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange?style=for-the-badge&logo=swift)](https://swift.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

*Transform your text with AI-powered improvements, anywhere on macOS*

[Download Latest Release](../../releases/latest) • [Features](#features) • [Installation](#installation) • [Usage](#usage)

</div>

## Overview

ProperType is a lightweight macOS menu bar application that uses OpenAI's GPT models to automatically improve text quality in real-time. Whether you're writing emails, documents, or social media posts, ProperType enhances your text with better grammar, spelling, clarity, and professionalism.

### ✨ Key Features

- **🚀 Global Hotkey**: Press `⌘⌥I` anywhere to improve selected text
- **🧠 AI-Powered**: Uses OpenAI GPT models for intelligent text enhancement
- **📱 Menu Bar Integration**: Lightweight, always-accessible interface
- **🔒 Privacy-Focused**: Text processing happens securely via OpenAI API
- **⚙️ Customizable**: Configure AI instructions to match your writing style
- **🎯 Universal**: Works in any macOS application
- **📋 Clipboard Support**: Improve text via clipboard when hotkeys aren't available

## Features

### Core Functionality
- **Real-time text improvement** with AI
- **Grammar and spelling correction**
- **Style and clarity enhancement**
- **Professional tone adjustment**
- **Custom AI prompt configuration**

### Technical Features
- Native Swift implementation
- Cocoa and InputMethodKit integration
- Secure API key storage using UserDefaults
- Accessibility API for global text selection
- Background processing with user notifications

## Installation

### Option 1: Download DMG (Recommended)
1. Download `ProperType-v1.0.dmg` from the [releases page](../../releases/latest)
2. Double-click to mount the DMG
3. Drag `ProperType.app` to your Applications folder
4. Launch ProperType from Applications

### Option 2: Build from Source
```bash
git clone https://github.com/your-username/ProperType.git
cd ProperType
chmod +x build.sh
./build.sh
```

## Setup

### 1. Get OpenAI API Key
1. Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. Create an account or log in
3. Generate a new API key
4. Copy the API key (starts with `sk-`)

### 2. Configure ProperType
1. Launch ProperType (you'll see "PT" in your menu bar)
2. Click the "PT" menu → "Configure OpenAI API Key"
3. Paste your API key and click "Save"

### 3. Enable Accessibility Permissions
1. Go to System Preferences → Privacy & Security → Accessibility
2. Click the lock to make changes
3. Add ProperType and enable it
4. The global hotkey `⌘⌥I` should now work

## Usage

### Global Hotkey Method
1. Select any text in any application
2. Press `⌘⌥I` (Command+Option+I)
3. Watch as your text is automatically improved and replaced

### Menu Bar Method
1. Copy text to your clipboard
2. Click "PT" in the menu bar
3. Select "Improve Clipboard Text"
4. Paste the improved text where needed

### Customization
- **AI Instructions**: Click "PT" → "Configure AI Instructions" to customize how the AI processes your text
- **System Prompt**: Modify the AI's behavior for different writing styles (formal, casual, technical, etc.)

## Examples

**Before:**
```
this is a quik test of the app and i hope it works good
```

**After:**
```
This is a quick test of the app, and I hope it works well.
```

**Before:**
```
hey can u send me the report when u get a chance thx
```

**After:**
```
Hello, could you please send me the report when you have a chance? Thank you.
```

## Requirements

- **macOS**: 10.15 (Catalina) or later
- **OpenAI API Key**: Required for text processing
- **Accessibility Permissions**: Required for global hotkey functionality
- **Internet Connection**: Required for API calls

## Privacy & Security

- Your text is sent to OpenAI's servers for processing
- API keys are stored securely in macOS UserDefaults
- No text is logged or stored locally by ProperType
- Follow OpenAI's data usage policies

## Development

### Project Structure
```
ProperType/
├── ProperType_Enhanced.swift  # Main application code
├── build.sh                   # Build and packaging script
├── LICENSE                    # MIT License
└── README.md                  # This file
```

### Building
```bash
# Build app bundle
./build.sh

# The script will:
# 1. Compile the Swift source
# 2. Create proper app bundle with Info.plist
# 3. Optionally install to /Applications/
# 4. Optionally create distribution DMG
```

### Architecture
- **AIService**: Handles OpenAI API communication
- **SettingsManager**: Manages user preferences and API keys
- **PermissionManager**: Handles accessibility permissions
- **HotkeyManager**: Manages global hotkey registration
- **ProperTypeMenuApp**: Main menu bar application

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### Hotkey Not Working
1. Check System Preferences → Privacy & Security → Accessibility
2. Remove old entries and re-add ProperType
3. Restart the application
4. Try running from `/Applications/` instead of development directory

### API Errors
1. Verify your OpenAI API key is correct
2. Check your OpenAI account has available credits
3. Ensure you have internet connectivity
4. Check the Console app for detailed error messages

### Permission Issues
1. Reset accessibility permissions: `sudo tccutil reset Accessibility`
2. Restart your Mac
3. Launch ProperType and grant permissions when prompted

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Swift and Cocoa
- Powered by OpenAI's GPT models
- Inspired by the need for better writing tools on macOS

## Support

- 🐛 [Report Bugs](../../issues)
- 💡 [Request Features](../../issues)
- 📧 [Contact](mailto:your-email@example.com)

---

<div align="center">
Made with ❤️ for the macOS community
</div>
