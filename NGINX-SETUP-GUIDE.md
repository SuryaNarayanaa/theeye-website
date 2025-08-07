# Nginx Reverse Proxy Setup Guide

This guide will help you set up the nginx reverse proxy configuration for your CTF application.

## 🎯 What We're Setting Up

- **Main Site**: Your React application at the root path (`/`)
- **CTF Proxy**: The CTF application proxied under `/ctf/` path
- **Path Rewriting**: All absolute paths in the CTF app are rewritten to include `/ctf/`

## 📋 Prerequisites

### Option 1: Docker (Recommended)
- Install Docker Desktop for Windows
- Download from: https://www.docker.com/products/docker-desktop/

### Option 2: Local Nginx Installation
- Install nginx on your system
- Windows: Use WSL or nginx for Windows
- Linux: `sudo apt-get install nginx` (Ubuntu/Debian)

## 🚀 Quick Start with Docker

### 1. Install Docker Desktop
1. Download Docker Desktop from https://www.docker.com/products/docker-desktop/
2. Install and restart your computer
3. Start Docker Desktop

### 2. Build and Run
```powershell
# Build the Docker image
docker build -t eyewebsite .

# Run the container
docker run -d --name eyewebsite -p 8080:80 eyewebsite

# Check if it's running
docker ps
```

### 3. Test the Setup
- **Main Site**: http://localhost:8080/
- **CTF App**: http://localhost:8080/ctf/

## 🛠️ Manual Nginx Setup (Alternative)

### 1. Install Nginx

#### Windows (WSL):
```bash
sudo apt update
sudo apt install nginx
```

#### Windows (Native):
1. Download nginx for Windows from http://nginx.org/en/download.html
2. Extract to `C:\nginx`
3. Add `C:\nginx` to your PATH

### 2. Configure Nginx

#### Copy Configuration Files:
1. Copy `nginx.conf` to your nginx installation directory
2. For Windows WSL: `/etc/nginx/nginx.conf`
3. For Windows native: `C:\nginx\conf\nginx.conf`

#### Update the Configuration:
Make sure the nginx.conf points to your CTF application URL:
```nginx
location /ctf/ {
    proxy_pass https://hidden-x.vercel.app/;
    # ... rest of configuration
}
```

### 3. Start Nginx

#### Windows WSL:
```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

#### Windows Native:
```cmd
cd C:\nginx
start nginx
```

## 🔧 Configuration Details

### Current Setup
Your nginx configuration includes:

1. **Main Application**: Serves your React app at `/`
2. **CTF Proxy**: Proxies `https://hidden-x.vercel.app/` under `/ctf/`
3. **Path Rewriting**: All absolute paths are rewritten to include `/ctf/`
4. **Security**: Headers are managed to prevent conflicts
5. **Caching**: Optimized caching for performance

### Key Features
- ✅ **Path Rewriting**: `href="/"` → `href="/ctf/"`
- ✅ **Security Headers**: Properly managed to avoid conflicts
- ✅ **Caching**: Static assets cached for 1 year
- ✅ **Compression**: Gzip compression enabled
- ✅ **Error Handling**: Proper error pages

## 🧪 Testing Your Setup

### 1. Test Main Site
```bash
curl http://localhost:8080/
# Should return your React app
```

### 2. Test CTF Proxy
```bash
curl http://localhost:8080/ctf/
# Should return the CTF app with rewritten paths
```

### 3. Test Path Rewriting
```bash
curl http://localhost:8080/ctf/ | grep "/ctf/"
# Should find rewritten paths
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```powershell
# Check what's using port 8080
netstat -ano | findstr :8080

# Kill the process or use a different port
docker run -d --name eyewebsite -p 8081:80 eyewebsite
```

#### 2. Docker Not Running
```powershell
# Start Docker Desktop
# Or check if Docker is running
docker --version
```

#### 3. Nginx Configuration Errors
```bash
# Test nginx configuration
nginx -t

# Check nginx logs
tail -f /var/log/nginx/error.log
```

#### 4. CTF App Not Loading
- Check if `https://hidden-x.vercel.app/` is accessible
- Verify the URL is correct in nginx.conf
- Check browser developer tools for errors

### Debug Commands

#### Docker Debugging:
```powershell
# View container logs
docker logs eyewebsite

# Enter container shell
docker exec -it eyewebsite sh

# Check nginx status inside container
docker exec eyewebsite nginx -t
```

#### Nginx Debugging:
```bash
# Test configuration
nginx -t

# Reload configuration
nginx -s reload

# Check error logs
tail -f /var/log/nginx/error.log
```

## 📊 Performance Optimization

### Current Optimizations:
- **Gzip Compression**: Enabled for text-based files
- **Static Asset Caching**: 1 year for static files
- **Proxy Caching**: 1 hour for proxy responses
- **Security Headers**: Properly configured

### Additional Optimizations:
```nginx
# Add to nginx.conf for better performance
proxy_buffering on;
proxy_buffer_size 4k;
proxy_buffers 8 4k;
proxy_busy_buffers_size 8k;
```

## 🔒 Security Considerations

### Current Security Features:
- ✅ **Security Headers**: X-Frame-Options, X-XSS-Protection, etc.
- ✅ **Hidden Files**: Denied access to `.` files
- ✅ **Backup Files**: Denied access to `~` files
- ✅ **CORS Handling**: Proper proxy headers

### Additional Security (Optional):
```nginx
# Rate limiting
limit_req_zone $binary_remote_addr zone=ctf:10m rate=10r/s;
location /ctf/ {
    limit_req zone=ctf burst=20 nodelay;
    # ... rest of config
}
```

## 🚀 Production Deployment

### Docker Production:
```powershell
# Build production image
docker build -t eyewebsite:prod .

# Run with restart policy
docker run -d --name eyewebsite-prod --restart unless-stopped -p 80:80 eyewebsite:prod
```

### Nginx Production:
```bash
# Copy configuration to production
sudo cp nginx.conf /etc/nginx/nginx.conf

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

## 📚 Next Steps

1. **Test the Setup**: Visit http://localhost:8080/ctf/
2. **Customize**: Update the CTF URL in nginx.conf if needed
3. **Monitor**: Check logs for any issues
4. **Deploy**: Move to production when ready

## 🆘 Getting Help

If you encounter issues:

1. **Check Logs**: Look at nginx error logs
2. **Test Connectivity**: Verify the CTF URL is accessible
3. **Browser Dev Tools**: Check for JavaScript errors
4. **Configuration**: Verify nginx.conf syntax

## 📞 Support

For additional help:
- Check the `REVERSE-PROXY-README.md` for detailed documentation
- Review nginx error logs for specific issues
- Test individual components step by step

---

**Configuration Version**: 1.0.0
**Last Updated**: $(date) 