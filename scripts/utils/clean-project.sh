#!/bin/bash

# AgriDirect - Project Cleanup Script

echo "🧹 Cleaning AgriDirect project..."

# Function to safely remove directories/files
safe_remove() {
    if [ -e "$1" ]; then
        echo "🗑️  Removing: $1"
        rm -rf "$1"
    fi
}

# Function to clean with confirmation
clean_with_confirmation() {
    read -p "❓ $1 (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

echo "Select cleaning level:"
echo "1) Quick clean (build artifacts, temp files)"
echo "2) Deep clean (+ node_modules, pods)"
echo "3) Nuclear clean (+ git ignored files)"
echo "4) Custom clean (choose what to clean)"
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "🚀 Performing quick clean..."
        QUICK_CLEAN=true
        ;;
    2)
        echo "🧼 Performing deep clean..."
        DEEP_CLEAN=true
        ;;
    3)
        echo "☢️  Performing nuclear clean..."
        if clean_with_confirmation "This will remove ALL git-ignored files. Continue?"; then
            NUCLEAR_CLEAN=true
        else
            echo "❌ Nuclear clean cancelled."
            exit 1
        fi
        ;;
    4)
        echo "🎛️  Custom clean mode..."
        CUSTOM_CLEAN=true
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

# Quick clean items
if [ "$QUICK_CLEAN" = true ] || [ "$DEEP_CLEAN" = true ] || [ "$NUCLEAR_CLEAN" = true ]; then
    echo ""
    echo "📂 Cleaning build artifacts..."
    safe_remove "build"
    safe_remove "dist"
    safe_remove ".expo"
    safe_remove ".metro-cache"
    
    # Android build artifacts
    echo "🤖 Cleaning Android build files..."
    safe_remove "android/build"
    safe_remove "android/app/build"
    safe_remove "android/.gradle"
    
    # iOS build artifacts  
    echo "🍎 Cleaning iOS build files..."
    safe_remove "ios/build"
    safe_remove "ios/DerivedData"
    find ios -name "*.xcarchive" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # React Native temp files
    echo "⚛️  Cleaning React Native temp files..."
    safe_remove "tmp"
    safe_remove ".tmp"
    safe_remove "node_modules/.cache"
    
    # Logs
    echo "📋 Cleaning log files..."
    find . -name "*.log" -type f -not -path "./node_modules/*" -delete 2>/dev/null || true
    safe_remove "logs"
    
    # OS generated files
    echo "🖥️  Cleaning OS generated files..."
    find . -name ".DS_Store" -delete 2>/dev/null || true
    find . -name "Thumbs.db" -delete 2>/dev/null || true
    find . -name "desktop.ini" -delete 2>/dev/null || true
fi

# Deep clean items
if [ "$DEEP_CLEAN" = true ] || [ "$NUCLEAR_CLEAN" = true ]; then
    echo ""
    echo "🔧 Deep cleaning dependencies..."
    
    if clean_with_confirmation "Remove node_modules?"; then
        safe_remove "node_modules"
        echo "💡 Run 'npm install' to reinstall dependencies"
    fi
    
    if clean_with_confirmation "Remove iOS Pods?"; then
        safe_remove "ios/Pods"
        safe_remove "ios/Podfile.lock"
        echo "💡 Run 'cd ios && pod install' to reinstall pods"
    fi
    
    # Package manager caches
    if clean_with_confirmation "Clear package manager caches?"; then
        echo "📦 Clearing npm cache..."
        npm cache clean --force 2>/dev/null || true
        
        if command -v yarn &> /dev/null; then
            echo "🧶 Clearing yarn cache..."
            yarn cache clean 2>/dev/null || true
        fi
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "🍫 Clearing CocoaPods cache..."
            pod cache clean --all 2>/dev/null || true
        fi
    fi
fi

# Nuclear clean
if [ "$NUCLEAR_CLEAN" = true ]; then
    echo ""
    echo "☢️  Nuclear cleaning (all git-ignored files)..."
    if [ -d ".git" ]; then
        git clean -fdx
        echo "⚠️  All git-ignored files have been removed!"
        echo "💡 You may need to:"
        echo "   - npm install"
        echo "   - cd ios && pod install"
        echo "   - Reconfigure any local settings"
    else
        echo "❌ Not a git repository. Cannot perform nuclear clean."
    fi
fi

# Custom clean
if [ "$CUSTOM_CLEAN" = true ]; then
    echo ""
    echo "🎛️  Choose what to clean:"
    
    if clean_with_confirmation "Clean build artifacts (build/, dist/, etc.)?"; then
        safe_remove "build"
        safe_remove "dist"
        safe_remove ".expo"
        safe_remove ".metro-cache"
    fi
    
    if clean_with_confirmation "Clean Android build files?"; then
        safe_remove "android/build"
        safe_remove "android/app/build"
        safe_remove "android/.gradle"
    fi
    
    if clean_with_confirmation "Clean iOS build files?"; then
        safe_remove "ios/build"
        safe_remove "ios/DerivedData"
    fi
    
    if clean_with_confirmation "Remove node_modules?"; then
        safe_remove "node_modules"
    fi
    
    if clean_with_confirmation "Remove iOS Pods?"; then
        safe_remove "ios/Pods"
        safe_remove "ios/Podfile.lock"
    fi
    
    if clean_with_confirmation "Clean log files?"; then
        find . -name "*.log" -type f -not -path "./node_modules/*" -delete 2>/dev/null || true
        safe_remove "logs"
    fi
    
    if clean_with_confirmation "Clean OS generated files (.DS_Store, etc.)?"; then
        find . -name ".DS_Store" -delete 2>/dev/null || true
        find . -name "Thumbs.db" -delete 2>/dev/null || true
        find . -name "desktop.ini" -delete 2>/dev/null || true
    fi
fi

# Show disk space saved (approximation)
echo ""
echo "🎉 Project cleanup completed!"
echo ""
echo "💡 Next steps:"
echo "   - Run 'npm install' if you removed node_modules"
echo "   - Run 'cd ios && pod install' if you removed Pods"
echo "   - Run './scripts/build/build-all.sh' to rebuild"
echo ""
echo "✨ Your AgriDirect project is now clean and ready!"