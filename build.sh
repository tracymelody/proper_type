#!/bin/bash

# ProperType Build Script
# This script compiles the ProperType Enhanced app

echo "🚀 Building ProperType Enhanced..."

# Create app bundle structure if it doesn't exist
mkdir -p ProperType.app/Contents/{MacOS,Resources}

# Create Info.plist for proper app identification
echo "📝 Creating Info.plist..."
cat > ProperType.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>ProperType</string>
    <key>CFBundleExecutable</key>
    <string>ProperType</string>
    <key>CFBundleIdentifier</key>
    <string>com.propertype.app</string>
    <key>CFBundleName</key>
    <string>ProperType</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 ProperType. All rights reserved.</string>
</dict>
</plist>
EOF

# Compile the Swift source
echo "📦 Compiling Swift source..."
swiftc -o ProperType.app/Contents/MacOS/ProperType ProperType_Enhanced.swift -framework Cocoa -framework Carbon

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📱 ProperType.app is ready to use"
    echo ""
    
    # Ask if user wants to install to Applications
    read -p "📥 Do you want to install ProperType to /Applications/? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 Installing to /Applications/..."
        
        # Remove old version if it exists
        if [ -d "/Applications/ProperType.app" ]; then
            echo "🗑️ Removing old version..."
            rm -rf "/Applications/ProperType.app"
        fi
        
        # Copy to Applications
        cp -R "ProperType.app" "/Applications/"
        
        if [ $? -eq 0 ]; then
            echo "✅ Successfully installed to /Applications/ProperType.app"
            echo ""
            echo "🚨 IMPORTANT: For accessibility permissions to work properly:"
            echo "1. Go to System Preferences → Privacy & Security → Accessibility"
            echo "2. Remove any old 'ProperType' or 'swift' entries"
            echo "3. Launch /Applications/ProperType.app"
            echo "4. Grant permissions when prompted"
            echo "5. The app should now detect permissions correctly"
            echo ""
            read -p "🚀 Launch ProperType now? (y/n): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                open "/Applications/ProperType.app"
            fi
        else
            echo "❌ Failed to install to Applications"
        fi
    else
        echo ""
        echo "To install manually:"
        echo "1. Copy ProperType.app to /Applications/"
        echo "2. Launch the app from Applications"
        echo "3. Configure your OpenAI API key"
        echo "4. Grant accessibility permissions when prompted"
    fi
    
    # Ask if user wants to create DMG for distribution
    echo ""
    read -p "📦 Create DMG file for distribution? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔨 Creating DMG file..."
        
        # Create a temporary directory for DMG contents
        DMG_DIR="ProperType_DMG_temp"
        rm -rf "$DMG_DIR"
        mkdir -p "$DMG_DIR"
        
        # Copy the app to DMG directory
        cp -R "ProperType.app" "$DMG_DIR/"
        
        # Create a nice README for the DMG
        cat > "$DMG_DIR/README.txt" << 'DMGEOF'
ProperType - AI-Powered Text Improvement Tool
===========================================

INSTALLATION:
1. Drag ProperType.app to your Applications folder
2. Launch ProperType from Applications
3. Configure your OpenAI API key when prompted
4. Grant accessibility permissions when requested

USAGE:
• Press ⌘⌥I (Command+Option+I) anywhere to improve selected text
• Or click the "PT" icon in your menu bar for options

FEATURES:
• Real-time text improvement using AI
• Works in any application
• Customizable AI instructions
• Secure API key storage

REQUIREMENTS:
• macOS 10.15 or later
• OpenAI API key (get one at platform.openai.com)
• Accessibility permissions for global hotkeys

For support: https://github.com/your-repo/ProperType
DMGEOF
        
        # Create Applications symlink for easy installation
        ln -s /Applications "$DMG_DIR/Applications"
        
        # Create the DMG
        DMG_NAME="ProperType-v1.0.dmg"
        rm -f "$DMG_NAME"
        
        hdiutil create -volname "ProperType" -srcfolder "$DMG_DIR" -ov -format UDZO "$DMG_NAME"
        
        if [ $? -eq 0 ]; then
            echo "✅ DMG created successfully: $DMG_NAME"
            echo "📂 File size: $(du -h "$DMG_NAME" | cut -f1)"
            echo ""
            echo "🚀 Your friend can now:"
            echo "1. Download $DMG_NAME"
            echo "2. Double-click to mount it"
            echo "3. Drag ProperType.app to Applications"
            echo "4. Launch and configure their OpenAI API key"
        else
            echo "❌ Failed to create DMG"
        fi
        
        # Cleanup
        rm -rf "$DMG_DIR"
    fi
    echo ""
    echo "Usage:"
    echo "• Press ⌘⌥I anywhere to improve selected text"
    echo "• Or use the 'PT' menu in the menu bar"
else
    echo "❌ Build failed!"
    exit 1
fi
