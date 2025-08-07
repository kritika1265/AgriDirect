#!/bin/bash

# AgriDirect - Directory Structure Setup Script
# File: scripts/setup/create-directories.sh
# Description: Creates the complete directory structure for AgriDirect Flutter app
# Usage: Run from project root directory
# Author: AgriDirect Development Team

echo "🌱 AgriDirect - Setting up project directory structure..."
echo "=================================================="

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from the project root directory (where pubspec.yaml is located)"
    exit 1
fi

echo "📁 Creating main directories..."

# Create main lib directory structure
mkdir -p lib/{screens,widgets,services,models,utils,providers,config}
mkdir -p lib/services/ml

# Create detailed screen directories if needed
mkdir -p lib/screens/{auth,home,disease,weather,tools,community}

# Create asset directories
echo "🖼️  Creating asset directories..."
mkdir -p assets/images/{onboarding,backgrounds,placeholders}
mkdir -p assets/images/icons/{weather,crops,tools,diseases,fertilizers,pests,navigation}
mkdir -p assets/animations/lottie
mkdir -p assets/fonts/{Inter,Poppins}
mkdir -p assets/models
mkdir -p assets/labels
mkdir -p assets/data

# Create test directories
echo "🧪 Creating test directories..."
mkdir -p test/{services,models,integration_test}

# Create documentation directories
echo "📚 Creating documentation directories..."
mkdir -p docs
mkdir -p firebase
mkdir -p scripts/{setup,build,deploy,utils}

# Create platform-specific directories (if they don't exist)
mkdir -p android/app/src/main
mkdir -p ios/Runner

# Create .gitkeep files to preserve empty directories
echo "📝 Creating .gitkeep files..."
find assets -type d -empty -exec touch {}/.gitkeep \;
find lib -type d -empty -exec touch {}/.gitkeep \;
find test -type d -empty -exec touch {}/.gitkeep \;
find docs -type d -empty -exec touch {}/.gitkeep \;

# Create environment files
echo "⚙️  Creating environment configuration..."
if [ ! -f ".env" ]; then
    cat > .env << 'EOL'
# AgriDirect Environment Variables
# Copy this file to .env.local for local development

# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_firebase_app_id

# External API Keys
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
WEATHER_API_KEY=your_weather_api_key
NEWS_API_KEY=your_news_api_key

# App Configuration
APP_NAME=AgriDirect
APP_VERSION=1.0.0
DEBUG_MODE=true
ENABLE_ANALYTICS=false

# ML Model Configuration
ML_MODEL_VERSION=1.0
ENABLE_LOCAL_ML=true
CLOUD_ML_ENDPOINT=https://your-ml-api.com

# Database Configuration
DB_HOST=localhost
DB_NAME=agridirect_local
EOL
    echo "✅ Created .env file with template variables"
fi

# Create .env.example file
if [ ! -f ".env.example" ]; then
    cp .env .env.example
    echo "✅ Created .env.example file"
fi

# Update .gitignore to include environment files
if [ -f ".gitignore" ]; then
    if ! grep -q "# Environment files" .gitignore; then
        cat >> .gitignore << 'EOL'

# Environment files
.env
.env.local
.env.production
.env.staging
.env.*.local

# IDE and Editor files
.vscode/
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOL
        echo "✅ Updated .gitignore with environment and IDE exclusions"
    fi
fi

# Create basic documentation files
echo "📖 Creating documentation templates..."

# Create README.md if it doesn't exist
if [ ! -f "README.md" ]; then
    cat > README.md << 'EOL'
# AgriDirect 🌱

AI-powered agricultural assistance app with disease detection, crop prediction, and farming tools.

## Features
- 🔍 Plant Disease Detection using AI/ML
- 🌾 Crop Prediction and Recommendations
- 🌤️ Weather Information and Forecasts
- 🛠️ Agricultural Tools Rental Platform
- 👥 Smart Connect - Community & Expert Network
- 📰 Agricultural News and Updates
- 📅 Crop Calendar and Farming Reminders
- 🏪 Marketplace for Agricultural Products

## Getting Started

### Prerequisites
- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.1.0)
- Android Studio / VS Code
- Firebase Account
- Google Maps API Key

### Installation
1. Clone the repository
2. Run setup script: `./scripts/setup/create-directories.sh`
3. Install dependencies: `flutter pub get`
4. Configure Firebase: Follow `docs/SETUP_GUIDE.md`
5. Run the app: `flutter run`

## Project Structure
See `docs/PROJECT_STRUCTURE.md` for detailed project organization.

## Documentation
- [Setup Guide](docs/SETUP_GUIDE.md)
- [API Documentation](docs/API_DOCUMENTATION.md)
- [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)
- [User Manual](docs/USER_MANUAL.md)

## Contributing
Please read our contributing guidelines before submitting pull requests.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
EOL
    echo "✅ Created README.md template"
fi

# Create analysis_options.yaml if it doesn't exist
if [ ! -f "analysis_options.yaml" ]; then
    cat > analysis_options.yaml << 'EOL'
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    prefer_const_declarations: true
    prefer_final_fields: true
    unnecessary_const: false
    unnecessary_new: false
    use_super_parameters: true
    require_trailing_commas: true
    avoid_print: true
    avoid_web_libraries_in_flutter: true
    prefer_relative_imports: true
    sort_constructors_first: true
    sort_unnamed_constructors_first: true
EOL
    echo "✅ Created analysis_options.yaml with linting rules"
fi

echo ""
echo "🎉 Directory structure setup completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Run 'flutter clean && flutter pub get' to refresh dependencies"
echo "2. Configure your .env file with actual API keys"
echo "3. Set up Firebase following the setup guide"
echo "4. Add your app icons and images to assets/images/"
echo "5. Start developing! 🚀"
echo ""
echo "📁 Created directories:"
echo "   ✅ lib/ - Main application code"
echo "   ✅ assets/ - Images, fonts, models, and data"
echo "   ✅ test/ - Testing suite"
echo "   ✅ docs/ - Documentation"
echo "   ✅ scripts/ - Build and utility scripts"
echo "   ✅ firebase/ - Firebase configuration"
echo ""
echo "📄 Created files:"
echo "   ✅ .env - Environment variables template"
echo "   ✅ .env.example - Environment variables example"
echo "   ✅ README.md - Project documentation"
echo "   ✅ analysis_options.yaml - Dart linting rules"
echo ""
echo "Happy coding! 🌱💻"