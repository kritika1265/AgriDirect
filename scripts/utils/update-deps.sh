#!/bin/bash

# AgriDirect - Dependencies Update Script

set -e

echo "📦 Updating AgriDirect dependencies..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the project root."
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Backup current package files
echo "💾 Creating backup of current dependencies..."
cp package.json package.json.backup
if [ -f "package-lock.json" ]; then
    cp package-lock.json package-lock.json.backup
fi
if [ -f "yarn.lock" ]; then
    cp yarn.lock yarn.lock.backup
fi

echo ""
echo "🔄 Select update method:"
echo "1) Check for outdated packages only"
echo "2) Update patch versions (safe)"
echo "3) Update minor versions (recommended)"
echo "4) Update major versions (breaking changes possible)"
echo "5) Interactive update (choose each package)"
echo "6) Update specific packages"
read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        echo "🔍 Checking for outdated packages..."
        
        if command_exists npm; then
            echo ""
            echo "📊 NPM Outdated Packages:"
            npm outdated || true
        fi
        
        if command_exists yarn; then
            echo ""
            echo "📊 Yarn Outdated Packages:"
            yarn outdated || true
        fi
        
        echo ""
        echo "✅ Check completed. No changes made."
        exit 0
        ;;
        
    2)
        echo "🔧 Updating patch versions (x.x.X)..."
        UPDATE_TYPE="patch"
        ;;
        
    3)
        echo "🔧 Updating minor versions (x.X.x)..."
        UPDATE_TYPE="minor"
        ;;
        
    4)
        echo "⚠️  Updating major versions (X.x.x)..."
        echo "🚨 Warning: This may introduce breaking changes!"
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Major update cancelled."
            exit 1
        fi
        UPDATE_TYPE="major"
        ;;
        
    5)
        echo "🎛️  Interactive update mode..."
        UPDATE_TYPE="interactive"
        ;;
        
    6)
        echo "📝 Updating specific packages..."
        echo "Enter package names separated by spaces:"
        read -p "Packages: " SPECIFIC_PACKAGES
        UPDATE_TYPE="specific"
        ;;
        
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

# Determine package manager
if [ -f "yarn.lock" ] && command_exists yarn; then
    PACKAGE_MANAGER="yarn"
    echo "🧶 Using Yarn package manager"
elif [ -f "package-lock.json" ] && command_exists npm; then
    PACKAGE_MANAGER="npm"
    echo "📦 Using NPM package manager"
elif command_exists npm; then
    PACKAGE_MANAGER="npm"
    echo "📦 Using NPM package manager (default)"
else
    echo "❌ No package manager found (npm/yarn required)"
    exit 1
fi

# Perform updates based on selection
case $UPDATE_TYPE in
    "patch"|"minor"|"major")
        if [ "$PACKAGE_MANAGER" = "yarn" ]; then
            if [ "$UPDATE_TYPE" = "patch" ]; then
                yarn upgrade --patch
            elif [ "$UPDATE_TYPE" = "minor" ]; then
                yarn upgrade --minor
            else
                yarn upgrade --latest
            fi
        else
            # NPM updates
            if [ "$UPDATE_TYPE" = "patch" ]; then
                npm update
            elif [ "$UPDATE_TYPE" = "minor" ]; then
                npm update --save
            else
                echo "🔧 Installing npm-check-updates for major updates..."
                npm install -g npm-check-updates 2>/dev/null || true
                if command_exists ncu; then
                    ncu -u
                    npm install
                else
                    echo "⚠️  Please install npm-check-updates globally: npm install -g npm-check-updates"
                    exit 1
                fi
            fi
        fi
        ;;
        
    "interactive")
        if command_exists ncu; then
            ncu -i
            if [ "$PACKAGE_MANAGER" = "yarn" ]; then
                yarn install
            else
                npm install
            fi
        else
            echo "🔧 Installing npm-check-updates for interactive mode..."
            npm install -g npm-check-updates
            ncu -i
            if [ "$PACKAGE_MANAGER" = "yarn" ]; then
                yarn install
            else
                npm install
            fi
        fi
        ;;
        
    "specific")
        if [ -n "$SPECIFIC_PACKAGES" ]; then
            echo "🔧 Updating specific packages: $SPECIFIC_PACKAGES"
            if [ "$PACKAGE_MANAGER" = "yarn" ]; then
                yarn upgrade $SPECIFIC_PACKAGES
            else
                npm install $SPECIFIC_PACKAGES@latest --save
            fi
        else
            echo "❌ No packages specified."
            exit 1
        fi
        ;;
esac

# Update React Native specific dependencies
echo ""
echo "⚛️  Checking React Native specific updates..."

# Check React Native version
RN_VERSION=$(node -p "require('./package.json').dependencies['react-native']" 2>/dev/null || echo "not found")
if [ "$RN_VERSION" != "not found" ]; then
    echo "📱 Current React Native version: $RN_VERSION"
    
    read -p "Update React Native to latest? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 Updating React Native..."
        if [ "$PACKAGE_MANAGER" = "yarn" ]; then
            yarn add react-native@latest
        else
            npm install react-native@latest --save
        fi
        
        echo "📱 Don't forget to run 'npx react-native upgrade' after testing!"
    fi
fi

# Update iOS dependencies
if [[ "$OSTYPE" == "darwin"* ]] && [ -f "ios/Podfile" ]; then
    echo ""
    echo "🍎 Updating iOS CocoaPods dependencies..."
    read -p "Update CocoaPods? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd ios
        pod update
        cd ..
        echo "✅ CocoaPods updated successfully!"
    fi
fi

# Update Android dependencies
if [ -f "android/build.gradle" ]; then
    echo ""
    echo "🤖 Android dependencies found."
    echo "💡 Consider updating Android Gradle Plugin and dependencies manually in:"
    echo "   - android/build.gradle (project level)"
    echo "   - android/app/build.gradle (app level)"
fi

# Show what changed
echo ""
echo "📊 Dependency Update Summary:"
echo "=============================="

if [ "$PACKAGE_MANAGER" = "yarn" ]; then
    if command_exists git && [ -d ".git" ]; then
        if git diff --name-only | grep -q "yarn.lock"; then
            echo "🔄 yarn.lock has been updated"
        fi
        if git diff --name-only | grep -q "package.json"; then
            echo "📝 package.json has been updated"
        fi
    fi
else
    if command_exists git && [ -d ".git" ]; then
        if git diff --name-only | grep -q "package-lock.json"; then
            echo "🔄 package-lock.json has been updated"
        fi
        if git diff --name-only | grep -q "package.json"; then
            echo "📝 package.json has been updated"
        fi
    fi
fi

# Security audit
echo ""
echo "🔒 Running security audit..."
if [ "$PACKAGE_MANAGER" = "yarn" ]; then
    yarn audit || true
else
    npm audit || true
fi

# Clean install recommendation
echo ""
echo "💡 Recommended next steps:"
echo "1. Test your app thoroughly"
echo "2. Run './scripts/build/build-all.sh' to ensure everything builds"
echo "3. If issues occur, restore from backup:"
echo "   - cp package.json.backup package.json"
if [ "$PACKAGE_MANAGER" = "yarn" ]; then
    echo "   - cp yarn.lock.backup yarn.lock"
    echo "   - yarn install"
else
    echo "   - cp package-lock.json.backup package-lock.json"
    echo "   - npm install"
fi

# Clean up backups on success
echo ""
read -p "🗑️  Remove backup files? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f package.json.backup package-lock.json.backup yarn.lock.backup
    echo "✅ Backup files removed"
fi

echo ""
echo "🎉 Dependencies update completed!"
echo "✨ Your AgriDirect project is up to date!"