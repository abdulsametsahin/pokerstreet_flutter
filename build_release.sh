#!/bin/bash

# PokerStreet Release Build Script
# This script builds both iOS IPA and Android App Bundle for release

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists flutter; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

if ! command_exists pod; then
    print_error "CocoaPods is not installed. Please install it with: sudo gem install cocoapods"
    exit 1
fi

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

print_status "Starting release build process in: $SCRIPT_DIR"

# Step 1: Clean everything
print_status "Cleaning Flutter project..."
flutter clean

print_status "Removing iOS build artifacts..."
if [ -d "ios/Pods" ]; then
    rm -rf ios/Pods
fi
if [ -d "ios/.symlinks" ]; then
    rm -rf ios/.symlinks
fi
if [ -f "ios/Podfile.lock" ]; then
    rm -f ios/Podfile.lock
fi

# Step 2: Get Flutter dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

# Step 3: Regenerate native splash
print_status "Regenerating native splash screens..."
dart run flutter_native_splash:create

# Step 4: Install iOS dependencies
print_status "Installing iOS dependencies..."
cd ios
pod install
cd ..

# Step 5: Build Android App Bundle
print_status "Building Android App Bundle..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    print_success "Android App Bundle built successfully!"
    print_status "Location: build/app/outputs/bundle/release/app-release.aab"
else
    print_error "Failed to build Android App Bundle"
    exit 1
fi

# Step 6: Build iOS IPA
print_status "Building iOS IPA..."
flutter build ipa

if [ $? -eq 0 ]; then
    print_success "iOS IPA built successfully!"
    print_status "Location: build/ios/ipa/"
else
    print_error "Failed to build iOS IPA"
    exit 1
fi

# Final summary
echo ""
print_success "🎉 Release build completed successfully!"
echo ""
print_status "Build artifacts created:"
echo "  📱 iOS IPA: build/ios/ipa/"
echo "  🤖 Android AAB: build/app/outputs/bundle/release/app-release.aab"
echo ""
print_status "Next steps for distribution:"
echo "  📱 iOS: Upload the IPA to App Store Connect using Transporter app or Xcode"
echo "  🤖 Android: Upload the AAB to Google Play Console"
echo ""
print_warning "Don't forget to update version numbers before release!"

# Optional: Open build directories
read -p "Do you want to open the build directories? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Opening build directories..."
    open build/ios/ipa/ &
    open build/app/outputs/bundle/release/ &
fi

print_success "Script completed! 🚀"
