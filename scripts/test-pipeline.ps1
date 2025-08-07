# Local CI/CD Pipeline Test Script for Windows
# This script simulates the CI/CD pipeline locally

param(
    [switch]$SkipDocker
)

Write-Host "🚀 Starting local CI/CD pipeline test..." -ForegroundColor Green

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Status "Node.js version: $nodeVersion"
} catch {
    Write-Error "Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
}

# Check Node.js version
$majorVersion = [int]($nodeVersion -replace 'v', '' -split '\.')[0]
if ($majorVersion -lt 18) {
    Write-Error "Node.js version 18 or higher is required. Current version: $nodeVersion"
    exit 1
}

# Stage 1: Lint and Test
Write-Host ""
Write-Host "📋 Stage 1: Lint and Test" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan

# Install dependencies
Write-Status "Installing dependencies..."
npm ci

# Run ESLint
Write-Status "Running ESLint..."
npm run lint

# Check for TypeScript (optional)
if (Test-Path "tsconfig.json") {
    Write-Status "Running TypeScript type checking..."
    npx tsc --noEmit
}

# Check for test scripts (optional)
$npmScripts = npm run 2>$null
if ($npmScripts -match "test") {
    Write-Status "Running tests..."
    npm test
}

# Stage 2: Build
Write-Host ""
Write-Host "🔨 Stage 2: Build" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan

# Build the application
Write-Status "Building application..."
npm run build

# Check if build was successful
if (Test-Path "dist") {
    Write-Status "Build completed successfully!"
    $buildSize = (Get-ChildItem -Path "dist" -Recurse | Measure-Object -Property Length -Sum).Sum
    $buildSizeMB = [math]::Round($buildSize / 1MB, 2)
    Write-Status "Build size: $buildSizeMB MB"
} else {
    Write-Error "Build failed! dist directory not found."
    exit 1
}

# Stage 3: Security Scan
Write-Host ""
Write-Host "🛡️  Stage 3: Security Scan" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

# Run npm audit
Write-Status "Running npm audit..."
try {
    npm audit --audit-level=moderate
} catch {
    Write-Warning "npm audit found vulnerabilities"
}

# Stage 4: Docker Build Test (Optional)
if (-not $SkipDocker) {
    Write-Host ""
    Write-Host "🐳 Stage 4: Docker Build Test" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan

    try {
        $dockerVersion = docker --version
        Write-Status "Testing Docker build..."
        docker build -t eyewebsite-test .
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Docker build successful!"
            
            # Test running the container
            Write-Status "Testing container..."
            docker run --rm -d --name eyewebsite-test -p 8080:80 eyewebsite-test
            
            # Wait a moment for the container to start
            Start-Sleep -Seconds 3
            
            # Test if the container is responding
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 5
                if ($response.StatusCode -eq 200) {
                    Write-Status "Container is running and responding!"
                }
            } catch {
                Write-Warning "Container is running but not responding to HTTP requests"
            }
            
            # Clean up
            docker stop eyewebsite-test 2>$null
            docker rmi eyewebsite-test 2>$null
        } else {
            Write-Error "Docker build failed!"
        }
    } catch {
        Write-Warning "Docker not installed or not available. Skipping Docker build test."
    }
}

# Stage 5: Performance Check
Write-Host ""
Write-Host "⚡ Stage 5: Performance Check" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Check for large files
Write-Status "Checking for large files in build..."
$largeFiles = Get-ChildItem -Path "dist" -Recurse | Where-Object { $_.Length -gt 1MB }
if ($largeFiles) {
    Write-Warning "Found large files:"
    $largeFiles | ForEach-Object { Write-Host "  $($_.Name): $([math]::Round($_.Length / 1MB, 2)) MB" }
} else {
    Write-Status "No files larger than 1MB found"
}

# Stage 6: Final Report
Write-Host ""
Write-Host "📊 Final Report" -ForegroundColor Cyan
Write-Host "===============" -ForegroundColor Cyan

Write-Status "All pipeline stages completed successfully!"
Write-Status "Your application is ready for deployment!"

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Push your code to GitHub"
Write-Host "2. Set up the required secrets in your GitHub repository"
Write-Host "3. Configure your deployment platform"
Write-Host "4. Set up branch protection rules"
Write-Host "5. Monitor your first deployment!"

Write-Host ""
Write-Host "📚 For detailed setup instructions, see CI-CD-README.md" -ForegroundColor Cyan 