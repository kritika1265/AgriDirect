#!/bin/bash

# AgriDirect - iOS Deployment Script

set -e

echo "🍎 Deploying AgriDirect iOS app..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: iOS deployment is only supported on macOS."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the project root."
    exit 1
fi

# Configuration
APP_NAME="AgriDirect"
BUNDLE_ID="com.agridirect.app"
BUILD_DIR="build/ios"

# Check deployment method
echo "📱 Select deployment method:"
echo "1) Install on connected iOS device"
echo "2) Install on iOS Simulator"
echo "3) Deploy to TestFlight (Beta)"
echo "4) Deploy to App Store (Production)"
echo "5) Generate IPA only"
read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo "📱 Installing on connected iOS device..."
        
        # Check if device is connected
        if ! xcrun devicectl list devices | grep -q "Connected"; then
            echo "❌ No iOS device found. Please connect an iOS device."
            exit 1
        fi
        
        # Build if not available
        if [ ! -d "$BUILD_DIR/DerivedData" ]; then
            echo "🔨 iOS build not found. Building..."
            ./scripts/build/build-ios.sh
        fi
        
        echo "📲 Installing app on device..."
        cd ios
        xcodebuild -workspace AgriDirect.xcworkspace \
                   -scheme AgriDirect \
                   -configuration Debug \
                   -sdk iphoneos \
                   -destination generic/platform=iOS \
                   -allowProvisioningUpdates \
                   build install
        cd ..
        echo "✅ App installed on device successfully!"
        ;;
        
    2)
        echo "🖥️ Installing on iOS Simulator..."
        
        # List available simulators
        echo "📱 Available simulators:"
        xcrun simctl list devices available | grep iPhone
        
        # Get default simulator
        SIMULATOR=$(xcrun simctl list devices available | grep iPhone | head -1 | sed 's/.*(\([^)]*\)).*/\1/')
        
        if [ -z "$SIMULATOR" ]; then
            echo "❌ No iOS simulator available."
            exit 1
        fi
        
        echo "🚀 Using simulator: $SIMULATOR"
        
        # Boot simulator if not running
        xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
        
        # Build for simulator
        cd ios
        xcodebuild -workspace AgriDirect.xcworkspace \
                   -scheme AgriDirect \
                   -configuration Debug \
                   -sdk iphonesimulator \
                   -destination "platform=iOS Simulator,id=$SIMULATOR" \
                   build
        
        # Install on simulator
        APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "AgriDirect.app" -type d | head -1)
        if [ -n "$APP_PATH" ]; then
            xcrun simctl install "$SIMULATOR" "$APP_PATH"
            xcrun simctl launch "$SIMULATOR" "$BUNDLE_ID"
        fi
        cd ..
        echo "✅ App installed and launched on simulator!"
        ;;
        
    3)
        echo "🧪 Deploying to TestFlight (Beta)..."
        
        # Check if IPA exists
        if [ ! -f "$BUILD_DIR/AgriDirect.ipa" ]; then
            echo "🔨 IPA not found. Building..."
            ./scripts/build/build-ios.sh
        fi
        
        # Upload using Xcode or fastlane
        if command -v fastlane &> /dev/null; then
            echo "🚀 Using Fastlane for TestFlight upload..."
            cd ios
            fastlane beta
            cd ..
        else
            echo "📤 Manual TestFlight upload:"
            echo "1. Open Xcode"
            echo "2. Window > Organizer"
            echo "3. Select your archive from: $BUILD_DIR/AgriDirect.xcarchive"
            echo "4. Click 'Distribute App'"
            echo "5. Select 'App Store Connect'"
            echo "6. Upload for TestFlight"
            echo ""
            echo "Or use Application Loader / Transporter:"
            echo "1. Open Transporter app"
            echo "2. Upload: $BUILD_DIR/AgriDirect.ipa"
        fi
        ;;
        
    4)
        echo "🏪 Deploying to App Store (Production)..."
        
        # Confirm production deployment
        read -p "⚠️  Are you sure you want to deploy to App Store PRODUCTION? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Production deployment cancelled."
            exit 1
        fi
        
        # Check if IPA exists
        if [ ! -f "$BUILD_DIR/AgriDirect.ipa" ]; then
            echo "🔨 IPA not found. Building..."
            ./scripts/build/build-ios.sh
        fi
        
        # Deploy using fastlane if available
        if command -v fastlane &> /dev/null; then
            echo "🚀 Using Fastlane for App Store deployment..."
            cd ios
            fastlane release
            cd ..
        else
            echo "📤 Manual App Store deployment:"
            echo "1. Upload to App Store Connect (same as TestFlight process)"
            echo "2. Go to https://appstoreconnect.apple.com"
            echo "3. Select your app"
            echo "4. Go to App Store tab"
            echo "5. Create new version"
            echo "6. Add release notes and metadata"
            echo "7. Submit for review"
            echo "8. Once approved, release to App Store"
        fi
        ;;
        
    5)
        echo "📦 Generating IPA..."
        ./scripts/build/build-ios.sh
        
        if [ -f "$BUILD_DIR/AgriDirect.ipa" ]; then
            echo "✅ IPA generated: $BUILD_DIR/AgriDirect.ipa"
            echo "📊 IPA size: $(du -h $BUILD_DIR/AgriDirect.ipa | cut -f1)"
        else
            echo "❌ Failed to generate IPA. Check build configuration."
        fi
        ;;
        
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "🎉 iOS deployment process completed!"

# Show deployment logs if available
if [ -f "ios/fastlane/logs/deployment.log" ]; then
    echo "📋 Deployment logs available at: ios/fastlane/logs/deployment.log"
fi