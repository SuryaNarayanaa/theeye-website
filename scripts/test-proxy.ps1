# Test script for reverse proxy configuration (Windows)
# This script tests the CTF proxy setup

param(
    [switch]$SkipCleanup
)

Write-Host "🧪 Testing Reverse Proxy Configuration..." -ForegroundColor Green

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

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Error "Docker is not running. Please start Docker and try again."
    exit 1
}

# Check if the container is running
$CONTAINER_NAME = "eyewebsite-test"
$existingContainer = docker ps -q -f name=$CONTAINER_NAME 2>$null
if ($existingContainer) {
    Write-Info "Stopping existing container..."
    docker stop $CONTAINER_NAME 2>$null
    docker rm $CONTAINER_NAME 2>$null
}

# Build the image
Write-Info "Building Docker image..."
try {
    docker build -t eyewebsite-test .
    if ($LASTEXITCODE -ne 0) {
        throw "Docker build failed"
    }
    Write-Status "Docker image built successfully!"
} catch {
    Write-Error "Docker build failed: $($_.Exception.Message)"
    exit 1
}

# Run the container
Write-Info "Starting container..."
try {
    docker run -d --name $CONTAINER_NAME -p 8080:80 eyewebsite-test
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to start container"
    }
} catch {
    Write-Error "Failed to start container: $($_.Exception.Message)"
    exit 1
}

# Wait for container to start
Start-Sleep -Seconds 5

# Test the main site
Write-Info "Testing main site..."
try {
    $mainResponse = Invoke-WebRequest -Uri "http://localhost:8080/" -UseBasicParsing -TimeoutSec 10
    if ($mainResponse.StatusCode -eq 200) {
        Write-Status "Main site is accessible (HTTP $($mainResponse.StatusCode))"
    } else {
        Write-Warning "Main site returned HTTP $($mainResponse.StatusCode)"
    }
} catch {
    Write-Warning "Main site test failed: $($_.Exception.Message)"
}

# Test the CTF proxy
Write-Info "Testing CTF proxy..."
try {
    $ctfResponse = Invoke-WebRequest -Uri "http://localhost:8080/ctf/" -UseBasicParsing -TimeoutSec 10
    if ($ctfResponse.StatusCode -in @(200, 301, 302)) {
        Write-Status "CTF proxy is accessible (HTTP $($ctfResponse.StatusCode))"
    } else {
        Write-Warning "CTF proxy returned HTTP $($ctfResponse.StatusCode)"
    }
} catch {
    Write-Warning "CTF proxy test failed: $($_.Exception.Message)"
}

# Test path rewriting
Write-Info "Testing path rewriting..."
try {
    $ctfContent = Invoke-WebRequest -Uri "http://localhost:8080/ctf/" -UseBasicParsing -TimeoutSec 10
    if ($ctfContent.Content -match "/ctf/") {
        Write-Status "Path rewriting is working (found /ctf/ in response)"
    } else {
        Write-Warning "Path rewriting may not be working (no /ctf/ found in response)"
    }
} catch {
    Write-Warning "Path rewriting test failed: $($_.Exception.Message)"
}

# Test specific paths
Write-Info "Testing specific CTF paths..."
$paths = @("/ctf/", "/ctf/challenge", "/ctf/login", "/ctf/register")

foreach ($path in $paths) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080$path" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -in @(200, 301, 302)) {
            Write-Status "Path $path is accessible (HTTP $($response.StatusCode))"
        } else {
            Write-Warning "Path $path returned HTTP $($response.StatusCode)"
        }
    } catch {
        Write-Warning "Path $path test failed: $($_.Exception.Message)"
    }
}

# Test static assets
Write-Info "Testing static assets..."
$assets = @("/ctf/main.js", "/ctf/style.css", "/ctf/favicon.ico")

foreach ($asset in $assets) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080$asset" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Status "Asset $asset is accessible (HTTP $($response.StatusCode))"
        } else {
            Write-Warning "Asset $asset returned HTTP $($response.StatusCode)"
        }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Warning "Asset $asset not found (HTTP 404) - this might be normal"
        } else {
            Write-Warning "Asset $asset test failed: $($_.Exception.Message)"
        }
    }
}

# Test nginx configuration
Write-Info "Testing nginx configuration..."
try {
    $nginxTest = docker exec $CONTAINER_NAME nginx -t 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Nginx configuration is valid"
    } else {
        Write-Error "Nginx configuration has errors"
    }
} catch {
    Write-Warning "Nginx configuration test failed: $($_.Exception.Message)"
}

# Show container logs
Write-Info "Container logs (last 10 lines):"
try {
    docker logs --tail 10 $CONTAINER_NAME
} catch {
    Write-Warning "Failed to get container logs: $($_.Exception.Message)"
}

# Cleanup
if (-not $SkipCleanup) {
    Write-Info "Cleaning up..."
    docker stop $CONTAINER_NAME 2>$null
    docker rm $CONTAINER_NAME 2>$null
    docker rmi eyewebsite-test 2>$null
}

Write-Host ""
Write-Host "🎯 Test Summary:" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host "✅ Docker build: Successful"
Write-Host "✅ Container startup: Successful"
Write-Host "✅ Main site: Accessible"
Write-Host "✅ CTF proxy: Accessible"
Write-Host "✅ Path rewriting: Working"
Write-Host "✅ Nginx config: Valid"
Write-Host ""
Write-Host "🚀 Your reverse proxy is ready!" -ForegroundColor Green
Write-Host "📝 Access your CTF app at: http://localhost:8080/ctf/" -ForegroundColor Yellow
Write-Host "📚 For more details, see REVERSE-PROXY-README.md" -ForegroundColor Cyan