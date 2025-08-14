#!/bin/bash

# Android Emulator Installer for macOS
# Usage: ./install_android_emulator.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Installing Android Emulator for Flutter on macOS${NC}"

# Configuration
ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
CMDLINE_TOOLS_VERSION="11076708"  # Latest version as of 2025
ANDROID_API_LEVEL="34"  # Android 14
SYSTEM_IMAGE="system-images;android-${ANDROID_API_LEVEL};google_apis;arm64-v8a"
AVD_NAME="flutter_emulator"

# Create Android SDK directory
echo -e "${YELLOW}📁 Creating Android SDK directory...${NC}"
mkdir -p "$ANDROID_SDK_ROOT"
cd "$ANDROID_SDK_ROOT"

# Download command line tools
echo -e "${YELLOW}⬇️  Downloading Android Command Line Tools...${NC}"
if [[ $(uname -m) == 'arm64' ]]; then
    # Apple Silicon Mac
    CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-mac-${CMDLINE_TOOLS_VERSION}_latest.zip"
else
    # Intel Mac
    CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-mac-${CMDLINE_TOOLS_VERSION}_latest.zip"
fi

curl -o cmdline-tools.zip "$CMDLINE_TOOLS_URL"
unzip -q cmdline-tools.zip
rm cmdline-tools.zip

# Move cmdline-tools to proper directory structure
mkdir -p cmdline-tools/latest
mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true

# Set up environment variables temporarily
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"

echo -e "${YELLOW}📦 Installing Android SDK packages...${NC}"
# Accept licenses first
yes | sdkmanager --licenses >/dev/null 2>&1

# Install required packages
sdkmanager "platform-tools" \
           "platforms;android-${ANDROID_API_LEVEL}" \
           "build-tools;34.0.0" \
           "emulator" \
           "$SYSTEM_IMAGE"

echo -e "${YELLOW}📱 Creating Android Virtual Device...${NC}"
# Delete existing AVD if it exists
if avdmanager list avd | grep -q "$AVD_NAME"; then
    avdmanager delete avd -n "$AVD_NAME"
fi

# Create new AVD
echo "no" | avdmanager create avd -n "$AVD_NAME" -k "$SYSTEM_IMAGE" -d "pixel_6"

# Add environment variables to shell profile
SHELL_PROFILE=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_PROFILE="$HOME/.bash_profile"
fi

if [[ -n "$SHELL_PROFILE" ]]; then
    echo -e "${YELLOW}⚙️  Adding environment variables to $SHELL_PROFILE...${NC}"
    
    # Check if ANDROID_SDK_ROOT is already set
    if ! grep -q "ANDROID_SDK_ROOT" "$SHELL_PROFILE"; then
        echo "" >> "$SHELL_PROFILE"
        echo "# Android SDK" >> "$SHELL_PROFILE"
        echo "export ANDROID_SDK_ROOT=\"\$HOME/Library/Android/sdk\"" >> "$SHELL_PROFILE"
        echo "export PATH=\"\$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:\$ANDROID_SDK_ROOT/platform-tools:\$ANDROID_SDK_ROOT/emulator:\$PATH\"" >> "$SHELL_PROFILE"
    fi
fi

# Create convenient scripts
echo -e "${YELLOW}📝 Creating convenience scripts...${NC}"
mkdir -p "$HOME/bin"

# Start emulator script
cat > "$HOME/bin/start-flutter-emulator" << 'EOF'
#!/bin/bash
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"
emulator -avd flutter_emulator
EOF

# List devices script
cat > "$HOME/bin/list-flutter-devices" << 'EOF'
#!/bin/bash
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"
echo "Available AVDs:"
avdmanager list avd
echo ""
echo "Flutter devices:"
flutter devices
EOF

chmod +x "$HOME/bin/start-flutter-emulator"
chmod +x "$HOME/bin/list-flutter-devices"

# Add ~/bin to PATH if not already there
if [[ -n "$SHELL_PROFILE" ]] && ! grep -q "\$HOME/bin" "$SHELL_PROFILE"; then
    echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$SHELL_PROFILE"
fi

echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Restart your terminal or run: source $SHELL_PROFILE"
echo "2. Start the emulator with: start-flutter-emulator"
echo "3. Or manually: emulator -avd flutter_emulator"
echo "4. Check Flutter devices: flutter devices"
echo "5. Run your Flutter app: flutter run"
echo ""
echo -e "${YELLOW}🔧 Useful commands:${NC}"
echo "• Start emulator: start-flutter-emulator"
echo "• List devices: list-flutter-devices"
echo "• Flutter doctor: flutter doctor"
echo ""
echo -e "${GREEN}Happy Flutter development! 🎉${NC}"