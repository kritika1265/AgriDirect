#!/bin/bash

# AgriDirect - Test Runner Script

set -e

echo "🧪 Running AgriDirect tests..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the project root."
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run tests with proper formatting
run_test_suite() {
    local suite_name=$1
    local command=$2
    local description=$3
    
    echo ""
    echo "🔍 Running $suite_name..."
    echo "📝 $description"
    echo "----------------------------------------"
    
    if eval $command; then
        echo "✅ $suite_name passed!"
        return 0
    else
        echo "❌ $suite_name failed!"
        return 1
    fi
}

# Initialize test results tracking
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0
FAILED_SUITE_NAMES=()

# Check test configuration
echo "🔧 Checking test environment..."

# Check if Jest is configured
if ! grep -q "jest" package.json; then
    echo "⚠️  Jest not found in package.json. Installing Jest..."
    npm install --save-dev jest @types/jest
fi

# Check if test scripts exist in package.json
if ! grep -q "\"test\"" package.json; then
    echo "⚠️  No test script found in package.json"
    echo "💡 Adding default test script..."
    
    # Backup package.json
    cp package.json package.json.backup
    
    # Add test script using Node.js
    node -e "
        const pkg = JSON.parse(require('fs').readFileSync('package.json', 'utf8'));
        if (!pkg.scripts) pkg.scripts = {};
        if (!pkg.scripts.test) pkg.scripts.test = 'jest';
        if (!pkg.scripts['test:watch']) pkg.scripts['test:watch'] = 'jest --watch';
        if (!pkg.scripts['test:coverage']) pkg.scripts['test:coverage'] = 'jest --coverage';
        if (!pkg.scripts['test:ci']) pkg.scripts['test:ci'] = 'jest --ci --coverage --watchAll=false';
        require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "
fi

echo ""
echo "🎯 Select test mode:"
echo "1) Run all tests"
echo "2) Run unit tests only"
echo "3) Run integration tests only"
echo "4) Run E2E tests only"
echo "5) Run with coverage report"
echo "6) Run in watch mode"
echo "7) Run specific test file/pattern"
echo "8) Run tests in CI mode"
read -p "Enter your choice (1-8): " choice

case $choice in
    1)
        echo "🚀 Running all tests..."
        TEST_MODE="all"
        ;;
    2)
        echo "🔬 Running unit tests only..."
        TEST_MODE="unit"
        ;;
    3)
        echo "🔗 Running integration tests only..."
        TEST_MODE="integration"
        ;;
    4)
        echo "🎭 Running E2E tests only..."
        TEST_MODE="e2e"
        ;;
    5)
        echo "📊 Running tests with coverage..."
        TEST_MODE="coverage"
        ;;
    6)
        echo "👀 Running tests in watch mode..."
        TEST_MODE="watch"
        ;;
    7)
        echo "🎯 Running specific test..."
        read -p "Enter test file pattern or path: " TEST_PATTERN
        TEST_MODE="specific"
        ;;
    8)
        echo "🤖 Running tests in CI mode..."
        TEST_MODE="ci"
        ;;
    *)
        echo "❌ Invalid choice. Running all tests by default."
        TEST_MODE="all"
        ;;
esac

# Pre-test setup
echo ""
echo "⚙️  Pre-test setup..."

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Create test directories if they don't exist
mkdir -p tests/{unit,integration,e2e}
mkdir -p src/__tests__

# Create basic test configuration if it doesn't exist
if [ ! -f "jest.config.js" ] && [ ! -f "jest.config.json" ]; then
    echo "⚙️  Creating Jest configuration..."
    cat > jest.config.js << 'EOF'
module.exports = {
  preset: 'react-native',
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  testPathIgnorePatterns: [
    '<rootDir>/node_modules/',
    '<rootDir>/android/',
    '<rootDir>/ios/'
  ],
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native|react-native-.*)/)'
  ],
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/__tests__/**',
    '!src/**/node_modules/**'
  ],
  coverageReporters: ['text', 'lcov', 'html'],
  coverageDirectory: 'coverage',
  testMatch: [
    '**/__tests__/**/*.(js|jsx|ts|tsx)',
    '**/?(*.)+(spec|test).(js|jsx|ts|tsx)'
  ]
};
EOF
fi

# Create test setup file if it doesn't exist
if [ ! -f "tests/setup.js" ]; then
    echo "⚙️  Creating test setup file..."
    cat > tests/setup.js << 'EOF'
// Jest setup for AgriDirect
import 'react-native-gesture-handler/jestSetup';

// Mock native modules
jest.mock('react-native-reanimated', () => {
  const Reanimated = require('react-native-reanimated/mock');
  Reanimated.default.call = () => {};
  return Reanimated;
});

// Mock async storage
jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock')
);

// Mock location services
jest.mock('@react-native-community/geolocation', () => ({
  getCurrentPosition: jest.fn(),
  watchPosition: jest.fn(),
}));

// Set up global test timeout
jest.setTimeout(10000);
EOF
fi

# Run tests based on selected mode
echo ""
echo "🧪 Starting test execution..."

case $TEST_MODE in
    "all")
        if run_test_suite "All Tests" "npm test" "Running complete test suite"; then
            ((PASSED_SUITES++))
        else
            ((FAILED_SUITES++))
            FAILED_SUITE_NAMES+=("All Tests")
        fi
        ((TOTAL_SUITES++))
        ;;
        
    "unit")
        if run_test_suite "Unit Tests" "npm test -- --testPathPattern=unit" "Running unit tests only"; then
            ((PASSED_SUITES++))
        else
            ((FAILED_SUITES++))
            FAILED_SUITE_NAMES+=("Unit Tests")
        fi
        ((TOTAL_SUITES++))
        ;;
        
    "integration")
        if run_test_suite "Integration Tests" "npm test -- --testPathPattern=integration" "Running integration tests only"; then
            ((PASSED_SUITES++))
        else
            ((FAILED_SUITES++))
            FAILED_SUITE_NAMES+=("Integration Tests")
        fi
        ((TOTAL_SUITES++))
        ;;
        
    "e2e")
        echo "🎭 Running E2E tests..."
        
        # Check if Detox is configured
        if command_exists detox; then
            echo "🤖 Using Detox for E2E testing..."
            if run_test_suite "E2E Tests (iOS)" "detox test --configuration ios.sim.debug" "Running iOS E2E tests"; then
                ((PASSED_SUITES++))
            else
                ((FAILED_SUITES++))
                FAILED_SUITE_NAMES+=("E2E Tests (iOS)")
            fi
            ((TOTAL_SUITES++))
            
            if run_test_suite "E2E Tests (Android)" "detox test --configuration android.emu.debug" "Running Android E2E tests"; then
                ((PASSED_SUITES++))
            else
                ((FAILED_SUITES++))
                FAILED_SUITE_NAMES+=("E2E Tests (Android)")
            fi
            ((TOTAL_SUITES++))
        else
            echo "⚠️  Detox not found. Running E2E tests with Jest..."
            if run_test_suite "E2E Tests" "npm test -- --testPathPattern=e2e" "Running E2E tests with Jest"; then
                ((PASSED_SUITES++))
            else
                ((FAILED_SUITES++))
                FAILED_SUITE_NAMES+=("E2E Tests")
            fi
            ((TOTAL_SUITES++))
        fi
        ;;
        
    "coverage")
        if run_test_suite "Tests with Coverage" "npm run test:coverage" "Running tests and generating coverage report"; then
            ((PASSED_SUITES++))
            echo ""
            echo "📊 Coverage report generated in 'coverage/' directory"
            if command_exists open && [[ "$OSTYPE" == "darwin"* ]]; then
                read -p "Open coverage report in browser? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    open coverage/lcov-report/index.html
                fi
            fi
        else
            ((FAILED_SUITES++))
            FAILED_SUITE_NAMES+=("Coverage Tests")
        fi
        ((TOTAL_SUITES++))
        ;;
        
    "watch")
        echo "👀 Starting tests in watch mode..."
        echo "Press 'q' to quit watch mode"
        npm run test:watch || true
        echo "👋 Watch mode ended"
        exit 0
        ;;
        
    "specific")
        if [ -n "$TEST_PATTERN" ]; then
            if run_test_suite "Specific Tests" "npm test -- --testNamePattern='$TEST_PATTERN'" "Running tests matching: $TEST_PATTERN"; then
                ((PASSED_SUITES++))
            else
                ((FAILED_SUITES++))
                FAILED_SUITE_NAMES+=("Specific Tests")
            fi
            ((TOTAL_SUITES++))
        else
            echo "❌ No test pattern specified"
            exit 1
        fi
        ;;
        
    "ci")
        if run_test_suite "CI Tests" "npm run test:ci" "Running tests in CI mode with coverage"; then
            ((PASSED_SUITES++))
        else
            ((FAILED_SUITES++))
            FAILED_SUITE_NAMES+=("CI Tests")
        fi
        ((TOTAL_SUITES++))
        ;;
esac

# Additional test suites (if requested to run all)
if [ "$TEST_MODE" = "all" ]; then
    echo ""
    echo "🔍 Running additional test suites..."
    
    # Lint tests
    if command_exists eslint || grep -q "eslint" package.json; then
        if run_test_suite "Lint Tests" "npx eslint src/ --ext .js,.jsx,.ts,.tsx" "Running ESLint code quality checks"; then
            ((PASSED_SUITES++))
        else
            ((FAILED_SUITES++))
            FAILED_SUITE_NAMES+=("Lint Tests")
        fi
        ((TOTAL_SUITES++))
    fi
    
    # Type checking (if TypeScript)
    if [ -f "tsconfig.json" ]; then
        if run_test_suite "Type Check" "npx tsc --noEmit" "Running TypeScript type checking"; then
            ((PASSED_SUITES++))
        else
            ((FAILED_SUITES++))
            FAILED_SUITE_NAMES+=("Type Check")
        fi
        ((TOTAL_SUITES++))
    fi
fi

# Test results summary
echo ""
echo "📊 Test Results Summary"
echo "======================"
echo "📝 Total test suites: $TOTAL_SUITES"
echo "✅ Passed: $PASSED_SUITES"
echo "❌ Failed: $FAILED_SUITES"

if [ ${#FAILED_SUITE_NAMES[@]} -gt 0 ]; then
    echo ""
    echo "❌ Failed test suites:"
    for suite in "${FAILED_SUITE_NAMES[@]}"; do
        echo "   - $suite"
    done
fi

echo ""
if [ $FAILED_SUITES -eq 0 ]; then
    echo "🎉 All tests passed! Your AgriDirect app is ready!"
    echo "✨ Great job maintaining code quality!"
    exit 0
else
    echo "⚠️  Some tests failed. Please review and fix the issues."
    echo "💡 Check the test output above for specific error details."
    exit 1
fi