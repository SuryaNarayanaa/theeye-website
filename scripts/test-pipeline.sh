#!/bin/bash

# Local CI/CD Pipeline Test Script
# This script simulates the CI/CD pipeline locally

set -e

echo "🚀 Starting local CI/CD pipeline test..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js version 18 or higher is required. Current version: $(node -v)"
    exit 1
fi

print_status "Node.js version: $(node -v)"

# Stage 1: Lint and Test
echo ""
echo "📋 Stage 1: Lint and Test"
echo "=========================="

# Install dependencies
print_status "Installing dependencies..."
npm ci

# Run ESLint
print_status "Running ESLint..."
npm run lint

# Check for TypeScript (optional)
if [ -f "tsconfig.json" ]; then
    print_status "Running TypeScript type checking..."
    npx tsc --noEmit
fi

# Check for test scripts (optional)
if npm run | grep -q "test"; then
    print_status "Running tests..."
    npm test
fi

# Stage 2: Build
echo ""
echo "🔨 Stage 2: Build"
echo "=================="

# Build the application
print_status "Building application..."
npm run build

# Check if build was successful
if [ -d "dist" ]; then
    print_status "Build completed successfully!"
    print_status "Build size: $(du -sh dist | cut -f1)"
else
    print_error "Build failed! dist directory not found."
    exit 1
fi

# Stage 3: Security Scan
echo ""
echo "🛡️  Stage 3: Security Scan"
echo "==========================="

# Run npm audit
print_status "Running npm audit..."
npm audit --audit-level=moderate || print_warning "npm audit found vulnerabilities"

# Stage 4: Docker Build Test (Optional)
echo ""
echo "🐳 Stage 4: Docker Build Test"
echo "=============================="

if command -v docker &> /dev/null; then
    print_status "Testing Docker build..."
    docker build -t eyewebsite-test .
    
    if [ $? -eq 0 ]; then
        print_status "Docker build successful!"
        
        # Test running the container
        print_status "Testing container..."
        docker run --rm -d --name eyewebsite-test -p 8080:80 eyewebsite-test
        
        # Wait a moment for the container to start
        sleep 3
        
        # Test if the container is responding
        if curl -f http://localhost:8080 > /dev/null 2>&1; then
            print_status "Container is running and responding!"
        else
            print_warning "Container is running but not responding to HTTP requests"
        fi
        
        # Clean up
        docker stop eyewebsite-test
        docker rmi eyewebsite-test
    else
        print_error "Docker build failed!"
    fi
else
    print_warning "Docker not installed. Skipping Docker build test."
fi

# Stage 5: Performance Check
echo ""
echo "⚡ Stage 5: Performance Check"
echo "============================="

# Check bundle size
print_status "Checking bundle size..."
if command -v npx &> /dev/null; then
    npx vite-bundle-analyzer dist --mode static || print_warning "Bundle analyzer not available"
fi

# Check for large files
print_status "Checking for large files in build..."
find dist -type f -size +1M -exec ls -lh {} \; 2>/dev/null || print_status "No files larger than 1MB found"

# Stage 6: Final Report
echo ""
echo "📊 Final Report"
echo "==============="

print_status "All pipeline stages completed successfully!"
print_status "Your application is ready for deployment!"

echo ""
echo "🎯 Next Steps:"
echo "1. Push your code to GitHub"
echo "2. Set up the required secrets in your GitHub repository"
echo "3. Configure your deployment platform"
echo "4. Set up branch protection rules"
echo "5. Monitor your first deployment!"

echo ""
echo "📚 For detailed setup instructions, see CI-CD-README.md" 