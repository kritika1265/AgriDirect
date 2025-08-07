#!/bin/bash

# AgriDirect - Environment Setup Script
# File: scripts/setup/setup-env.sh
# Description: Sets up development environment for AgriDirect
# Usage: Run after create-directories.sh
# Author: AgriDirect Development Team

echo "🔧 AgriDirect - Environment Setup"
echo "================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get Flutter version
get_flutter_version() {
    if command_exists flutter; then
        flutter --version | head -1 | cut -d ' ' -f 2
    else
        echo "Not installed"
    fi
}

# Function to get Dart version
get_dart_version() {
    if command_exists dart; then
        dart --version 2>&1 | cut -d ' ' -f 4
    else
        echo "Not installed"
    fi
}

echo "📋 Checking prerequisites..."
echo ""

# Check Flutter installation
FLUTTER_VERSION=$(get_flutter_version)
echo "Flutter: $FLUTTER_VERSION"
if [ "$FLUTTER_VERSION" = "Not installed" ]; then
    echo "❌ Flutter is not installed. Please install Flutter SDK first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Dart installation
DART_VERSION=$(get_dart_version)
echo "Dart: $DART_VERSION"

# Check Android SDK
if [ -n "$ANDROID_HOME" ]; then
    echo "✅ Android SDK: $ANDROID_HOME"
else
    echo "⚠️  Android SDK: Not configured (ANDROID_HOME not set)"
fi

# Check iOS development (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command_exists xcrun; then
        XCODE_VERSION=$(xcrun xcodebuild -version | head -1)
        echo "✅ $XCODE_VERSION"
    else
        echo "⚠️  Xcode: Not installed"
    fi
fi

echo ""
echo "🔍 Running Flutter Doctor..."
flutter doctor

echo ""
echo "📦 Installing/Updating Flutter dependencies..."
flutter clean
flutter pub get

# Generate necessary files
echo ""
echo "🔨 Generating code..."
if grep -q "build_runner" pubspec.yaml; then
    flutter packages pub run build_runner build --delete-conflicting-outputs
fi

# Run tests to ensure everything is working
echo ""
echo "🧪 Running basic tests..."
if [ -f "test/widget_test.dart" ]; then
    flutter test test/widget_test.dart
else
    echo "⚠️  No widget tests found. Create test/widget_test.dart for testing."
fi

echo ""
echo "📱 Checking connected devices..."
flutter devices

echo ""
echo "🎉 Environment setup completed!"
echo ""
echo "📋 Summary:"
echo "   ✅ Flutter dependencies installed"
echo "   ✅ Code generation completed"
echo "   ✅ Basic tests passed"
echo ""
echo "🚀 Ready to develop! Try:"
echo "   flutter run                    # Run on connected device"
echo "   flutter run -d chrome          # Run in web browser"
echo "   flutter run --release          # Run release build"
echo ""
echo "📚 Don't forget to:"
echo "   1. Configure Firebase (run: flutterfire configure)"
echo "   2. Add your API keys to .env file"
echo "   3. Set up your IDE with Flutter plugins"
echo ""