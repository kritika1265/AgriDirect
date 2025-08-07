#!/bin/bash

# Script to create missing asset directories and files for AgriDirect Flutter app
# Run this script from your project root directory (where pubspec.yaml is located)

echo "🌱 Creating missing asset directories and files for AgriDirect..."

# Create missing image directories
echo "📁 Creating image directories..."
mkdir -p assets/images/onboarding
mkdir -p assets/images/backgrounds
mkdir -p assets/images/placeholders

# Create missing icon directories
echo "🎨 Creating icon directories..."
mkdir -p assets/images/icons/weather
mkdir -p assets/images/icons/crops
mkdir -p assets/images/icons/tools
mkdir -p assets/images/icons/diseases
mkdir -p assets/images/icons/fertilizers
mkdir -p assets/images/icons/pests
mkdir -p assets/images/icons/navigation

# Create missing model directories
echo "🤖 Creating ML model directories..."
mkdir -p assets/models/disease_detection
mkdir -p assets/models/crop_prediction
mkdir -p assets/labels

# Create missing data directories
echo "📊 Creating data directories..."
mkdir -p assets/data/crops
mkdir -p assets/data/weather
mkdir -p assets/data/diseases

# Create missing animation directories
echo "🎬 Creating animation directories..."
mkdir -p assets/animations/lottie

# Create missing documentation directories
echo "📚 Creating documentation directories..."
mkdir -p assets/docs/user_guide

# Create missing font directories
echo "🔤 Creating font directories..."
mkdir -p assets/fonts/Roboto
mkdir -p assets/fonts/OpenSans

# Create missing environment files
echo "⚙️  Creating environment files..."
touch .env.production
touch .env.staging

# Add placeholder content to environment files
echo "# Production environment variables" > .env.production
echo "# Add your production Firebase config and API keys here" >> .env.production

echo "# Staging environment variables" > .env.staging
echo "# Add your staging Firebase config and API keys here" >> .env.staging

# Create placeholder README files in directories to keep them in version control
echo "📝 Creating placeholder README files..."

# Create README files in key directories
cat > assets/images/README.md << 'EOF'
# Images Directory

This directory contains all image assets for the AgriDirect app.

## Structure
- `onboarding/` - Onboarding screen images
- `backgrounds/` - Background images
- `placeholders/` - Placeholder images
- `icons/` - Categorized icon sets
  - `weather/` - Weather-related icons
  - `crops/` - Crop and plant icons
  - `tools/` - Farming tool icons
  - `diseases/` - Disease identification icons
  - `fertilizers/` - Fertilizer icons
  - `pests/` - Pest identification icons
  - `navigation/` - Navigation UI icons

## Usage
Place your image assets in the appropriate subdirectories and reference them in your Flutter code.
EOF

cat > assets/models/README.md << 'EOF'
# ML Models Directory

This directory contains machine learning models for the AgriDirect app.

## Structure
- `disease_detection/` - TensorFlow Lite models for plant disease detection
- `crop_prediction/` - Models for crop yield prediction

## Model Files
Place your `.tflite` model files and associated label files here.
Make sure to update the model loading paths in your Flutter code accordingly.
EOF

cat > assets/data/README.md << 'EOF'
# Data Directory

This directory contains static data files for the AgriDirect app.

## Structure
- `crops/` - Crop-related data files (JSON, CSV)
- `weather/` - Weather pattern data
- `diseases/` - Disease information and treatment data

## File Formats
Supported formats: JSON, CSV, XML
Ensure proper encoding (UTF-8) for international character support.
EOF

cat > assets/animations/README.md << 'EOF'
# Animations Directory

This directory contains animation assets for the AgriDirect app.

## Structure
- `lottie/` - Lottie animation files (.json)

## Usage
Place your Lottie animation JSON files in the lottie/ subdirectory.
Reference them using the Lottie package in your Flutter widgets.
EOF

cat > assets/docs/README.md << 'EOF'
# Documentation Directory

This directory contains user documentation and guides.

## Structure
- `user_guide/` - User guide documents and images

## Formats
Supported formats: Markdown, PDF, HTML
Keep documentation up to date with app features.
EOF

# Create .gitkeep files to ensure empty directories are tracked by Git
find assets -type d -empty -exec touch {}/.gitkeep \;

echo "✅ All asset directories and files have been created!"
echo ""
echo "📋 Summary of created directories:"
echo "   - assets/images/* (with subdirectories)"
echo "   - assets/models/* (with subdirectories)"
echo "   - assets/data/* (with subdirectories)"
echo "   - assets/animations/lottie/"
echo "   - assets/docs/user_guide/"
echo "   - assets/fonts/* (font directories)"
echo ""
echo "📄 Created files:"
echo "   - .env.production"
echo "   - .env.staging"
echo "   - README.md files in major directories"
echo "   - .gitkeep files in empty directories"
echo ""
echo "⚠️  Next steps:"
echo "1. Add your actual asset files to the appropriate directories"
echo "2. Update the dependencies sorting in pubspec.yaml (see next artifact)"
echo "3. Run 'flutter pub get' to refresh dependencies"
echo "4. Add your Firebase configuration and API keys to the .env files"
echo ""
echo "🎉 Your AgriDirect project structure is now ready!"