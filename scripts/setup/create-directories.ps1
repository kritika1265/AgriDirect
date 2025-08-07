# AgriDirect - Directory Structure Setup Script (PowerShell)
# File: scripts/setup/create-directories.ps1
# Description: Creates the complete directory structure for AgriDirect Flutter app
# Usage: Run from project root directory in PowerShell
# Author: AgriDirect Development Team

Write-Host "🌱 AgriDirect - Setting up project directory structure..." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Check if we're in the project root
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: Please run this script from the project root directory (where pubspec.yaml is located)" -ForegroundColor Red
    exit 1
}

Write-Host "📁 Creating main directories..." -ForegroundColor Cyan

# Define all directories to create
$directories = @(
    # Main lib structure
    "lib\screens", "lib\widgets", "lib\services", "lib\models", "lib\utils", "lib\providers", "lib\config",
    "lib\services\ml",
    
    # Detailed screen directories
    "lib\screens\auth", "lib\screens\home", "lib\screens\disease", "lib\screens\weather", 
    "lib\screens\tools", "lib\screens\community",
    
    # Asset directories
    "assets\images", "assets\images\onboarding", "assets\images\backgrounds", "assets\images\placeholders",
    "assets\images\icons\weather", "assets\images\icons\crops", "assets\images\icons\tools", 
    "assets\images\icons\diseases", "assets\images\icons\fertilizers", "assets\images\icons\pests", 
    "assets\images\icons\navigation",
    "assets\animations\lottie",
    "assets\fonts\Inter", "assets\fonts\Poppins",
    "assets\models", "assets\labels", "assets\data",
    
    # Test directories
    "test\services", "test\models", "test\integration_test",
    
    # Documentation and scripts
    "docs", "firebase",
    "scripts\setup", "scripts\build", "scripts\deploy", "scripts\utils",
    
    # Platform directories
    "android\app\src\main", "ios\Runner"
)

# Create directories
foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "   ✅ Created: $dir" -ForegroundColor Green
}

Write-Host "📝 Creating .gitkeep files for empty directories..." -ForegroundColor Cyan

# Create .gitkeep files to preserve empty directories
$assetDirs = Get-ChildItem -Path "assets" -Directory -Recurse
foreach ($dir in $assetDirs) {
    if ((Get-ChildItem $dir.FullName -Force | Measure-Object).Count -eq 0) {
        New-Item -ItemType File -Force -Path "$($dir.FullName)\.gitkeep" | Out-Null
    }
}

$libDirs = Get-ChildItem -Path "lib" -Directory -Recurse
foreach ($dir in $libDirs) {
    if ((Get-ChildItem $dir.FullName -Force | Measure-Object).Count -eq 0) {
        New-Item -ItemType File -Force -Path "$($dir.FullName)\.gitkeep" | Out-Null
    }
}

Write-Host "⚙️  Creating environment configuration..." -ForegroundColor Cyan

# Create .env file if it doesn't exist
if (-not (Test-Path ".env")) {
    $envContent = @"
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
"@
    
    Set-Content -Path ".env" -Value $envContent -Encoding UTF8
    Write-Host "   ✅ Created .env file with template variables" -ForegroundColor Green
}

# Create .env.example file
if (-not (Test-Path ".env.example")) {
    Copy-Item ".env" ".env.example"
    Write-Host "   ✅ Created .env.example file" -ForegroundColor Green
}

# Update .gitignore
Write-Host "📄 Updating .gitignore..." -ForegroundColor Cyan
if (Test-Path ".gitignore") {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    if (-not $gitignoreContent.Contains("# Environment files")) {
        $additionalIgnores = @"

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
"@
        Add-Content -Path ".gitignore" -Value $additionalIgnores -Encoding UTF8
        Write-Host "   ✅ Updated .gitignore with environment and IDE exclusions" -ForegroundColor Green
    }
}

Write-Host "📖 Creating documentation templates..." -ForegroundColor Cyan

# Create README.md if it doesn't exist
if (-not (Test-Path "README.md")) {
    $readmeContent = @"
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
2. Run setup script: ``.\scripts\setup\create-directories.ps1``
3. Install dependencies: ``flutter pub get``
4. Configure Firebase: Follow ``docs/SETUP_GUIDE.md``
5. Run the app: ``flutter run``

## Project Structure
See ``docs/PROJECT_STRUCTURE.md`` for detailed project organization.

## Documentation
- [Setup Guide](docs/SETUP_GUIDE.md)
- [API Documentation](docs/API_DOCUMENTATION.md)
- [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)
- [User Manual](docs/USER_MANUAL.md)

## Contributing
Please read our contributing guidelines before submitting pull requests.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
"@
    
    Set-Content -Path "README.md" -Value $readmeContent -Encoding UTF8
    Write-Host "   ✅ Created README.md template" -ForegroundColor Green
}

# Create analysis_options.yaml if it doesn't exist
if (-not (Test-Path "analysis_options.yaml")) {
    $analysisContent = @"
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
"@
    
    Set-Content -Path "analysis_options.yaml" -Value $analysisContent -Encoding UTF8
    Write-Host "   ✅ Created analysis_options.yaml with linting rules" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Directory structure setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Run 'flutter clean && flutter pub get' to refresh dependencies"
Write-Host "2. Configure your .env file with actual API keys"
Write-Host "3. Set up Firebase following the setup guide"
Write-Host "4. Add your app icons and images to assets/images/"
Write-Host "5. Start developing! 🚀"
Write-Host ""
Write-Host "📁 Created directories:" -ForegroundColor Cyan
Write-Host "   ✅ lib/ - Main application code"
Write-Host "   ✅ assets/ - Images, fonts, models, and data"
Write-Host "   ✅ test/ - Testing suite"
Write-Host "   ✅ docs/ - Documentation"
Write-Host "   ✅ scripts/ - Build and utility scripts"
Write-Host "   ✅ firebase/ - Firebase configuration"
Write-Host ""
Write-Host "📄 Created files:" -ForegroundColor Cyan
Write-Host "   ✅ .env - Environment variables template"
Write-Host "   ✅ .env.example - Environment variables example"
Write-Host "   ✅ README.md - Project documentation"
Write-Host "   ✅ analysis_options.yaml - Dart linting rules"
Write-Host ""
Write-Host "Happy coding! 🌱💻" -ForegroundColor Green

# Pause to show results
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")