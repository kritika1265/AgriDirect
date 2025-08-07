#!/bin/bash

# AgriDirect - Android Deployment Script

set -e

echo "🚀 Deploying AgriDirect Android app..."

# Configuration
PLAY_STORE_PACKAGE="com.agridirect.app"
KEYSTORE_PATH="android/app/my-release-key.keystore"
BUILD_DIR="build/android"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the project root."
    exit 1
fi

# Check deployment method
echo "📱 Select deployment method:"
echo "1) Install on connected device/emulator"
echo "2) Deploy to Google Play Store (Internal Testing)"
echo "3) Deploy to Google Play Store (Production)"
echo "4) Generate signed APK only"
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "📱 Installing on connected device/emulator..."
        
        # Check if device is connected
        if ! adb devices | grep -q "device$"; then
            echo "❌ No Android device/emulator found. Please connect a device or start an emulator."
            exit 1
        fi
        
        # Install debug APK if available, otherwise build it
        if [ ! -f "$BUILD_DIR/agridirect-debug.apk" ]; then
            echo "🔨 Debug APK not found. Building..."
            ./scripts/build/build-android.sh
        fi
        
        echo "📲 Installing APK on device..."
        adb install -r "$BUILD_DIR/agridirect-debug.apk"
        
        # Launch the app
        adb shell am start -n "$PLAY_STORE_PACKAGE/.MainActivity"
        echo "✅ App installed and launched successfully!"
        ;;
        
    2)
        echo "🧪 Deploying to Google Play Store (Internal Testing)..."
        
        # Check if release APK exists
        if [ ! -f "$BUILD_DIR/agridirect-release.apk" ]; then
            echo "🔨 Release APK not found. Building..."
            ./scripts/build/build-android.sh
        fi
        
        # Check if fastlane is available
        if command -v fastlane &> /dev/null; then
            echo "🚀 Using Fastlane for deployment..."
            cd android
            fastlane internal
            cd ..
        else
            echo "📤 Manual deployment required:"
            echo "1. Go to https://play.google.com/console"
            echo "2. Select your app: $PLAY_STORE_PACKAGE"
            echo "3. Go to Testing > Internal testing"
            echo "4. Create new release and upload: $BUILD_DIR/agridirect-release.apk"
            echo "5. Fill release notes and submit for review"
        fi
        ;;
        
    3)
        echo "🏪 Deploying to Google Play Store (Production)..."
        
        # Additional checks for production
        if [ ! -f "$KEYSTORE_PATH" ]; then
            echo "❌ Release keystore not found. Production deployment requires a signed release."
            exit 1
        fi
        
        # Confirm production deployment
        read -p "⚠️  Are you sure you want to deploy to PRODUCTION? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Production deployment cancelled."
            exit 1
        fi
        
        # Check if release APK exists
        if [ ! -f "$BUILD_DIR/agridirect-release.apk" ]; then
            echo "🔨 Release APK not found. Building..."
            ./scripts/build/build-android.sh
        fi
        
        # Deploy using fastlane if available
        if command -v fastlane &> /dev/null; then
            echo "🚀 Using Fastlane for production deployment..."
            cd android
            fastlane production
            cd ..
        else
            echo "📤 Manual production deployment:"
            echo "1. Go to https://play.google.com/console"
            echo "2. Select your app: $PLAY_STORE_PACKAGE"
            echo "3. Go to Production"
            echo "4. Create new release and upload: $BUILD_DIR/agridirect-release.apk"
            echo "5. Fill release notes and submit for review"
            echo "6. Once approved, roll out to users"
        fi
        ;;
        
    4)
        echo "📦 Generating signed APK..."
        ./scripts/build/build-android.sh
        
        if [ -f "$BUILD_DIR/agridirect-release.apk" ]; then
            echo "✅ Signed APK generated: $BUILD_DIR/agridirect-release.apk"
            echo "📊 APK size: $(du -h $BUILD_DIR/agridirect-release.apk | cut -f1)"
        else
            echo "❌ Failed to generate signed APK. Check keystore configuration."
        fi
        ;;
        
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "🎉 Android deployment process completed!"

# Show deployment logs if available
if [ -f "android/fastlane/logs/deployment.log" ]; then
    echo "📋 Deployment logs available at: android/fastlane/logs/deployment.log"
fi