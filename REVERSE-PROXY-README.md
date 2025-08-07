# Reverse Proxy with Path Rewriting

This setup allows you to serve the CTF application under the `/ctf` path while rewriting all internal paths to work correctly.

## 🎯 Problem Solved

Most frontend applications expect to run at the root path (`/`), not under a subdirectory (`/ctf`). This creates issues with:

- Static file references (`/main.js`, `/style.css`)
- Absolute URLs in HTML, CSS, and JavaScript
- CORS protections and security headers

## ✅ Solution Overview

The nginx configuration uses the `ngx_http_sub_module` to rewrite all absolute paths in HTML, CSS, and JavaScript responses, making the CTF application work seamlessly under `/ctf`.

## 🔧 Configuration Details

### Nginx Location Block

```nginx
location /ctf/ {
    proxy_pass https://ctf.vercel.app/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    proxy_redirect off;

    # Rewriting absolute paths in HTML, CSS, JS
    sub_filter_types text/html text/css application/javascript;
    sub_filter_once off;
    sub_filter 'href="/' 'href="/ctf/';
    sub_filter 'src="/' 'src="/ctf/';
    sub_filter 'action="/' 'action="/ctf/';
    sub_filter 'url("/' 'url("/ctf/';
    sub_filter 'url(\'/' 'url(\'/ctf/';
    sub_filter 'url(/' 'url(/ctf/';

    # Hide security headers that might block resources
    proxy_hide_header X-Frame-Options;
    proxy_hide_header X-Content-Type-Options;
    proxy_hide_header Content-Security-Policy;
    proxy_hide_header X-XSS-Protection;

    # Cache proxy responses
    proxy_cache_valid 200 1h;
    proxy_cache_valid 404 1m;
}
```

### Path Rewriting Examples

| Original Path | Rewritten Path |
|---------------|----------------|
| `href="/"` | `href="/ctf/"` |
| `src="/main.js"` | `src="/ctf/main.js"` |
| `action="/submit"` | `action="/ctf/submit"` |
| `url("/api/data")` | `url("/ctf/api/data")` |

## 🚀 How It Works

### 1. Request Flow
```
User Request: https://yourdomain.com/ctf/challenge
↓
Nginx Proxy: https://ctf.vercel.app/challenge
↓
Response Processing: Rewrite all absolute paths
↓
User Receives: Modified HTML/CSS/JS with /ctf/ prefixes
```

### 2. Path Rewriting Process
- **HTML**: All `href`, `src`, and `action` attributes are rewritten
- **CSS**: All `url()` functions are rewritten
- **JavaScript**: All absolute paths in JavaScript are rewritten

### 3. Security Considerations
- Security headers from the proxied site are hidden to prevent blocking
- CORS issues are resolved by the proxy
- Original site's security is maintained

## 🛠️ Setup Instructions

### 1. Update nginx.conf
The configuration is already included in your `nginx.conf` file.

### 2. Update Dockerfile
The Dockerfile has been updated to copy the nginx configuration:
```dockerfile
COPY nginx.conf /etc/nginx/nginx.conf
```

### 3. Build and Deploy
```bash
# Build the Docker image
docker build -t eyewebsite .

# Run the container
docker run -p 80:80 eyewebsite
```

## 🧪 Testing

### Test URLs
- **Main Site**: `http://localhost/`
- **CTF App**: `http://localhost/ctf/`
- **CTF Challenge**: `http://localhost/ctf/challenge`

### Verification Steps
1. Visit `http://localhost/ctf/`
2. Check browser developer tools
3. Verify all resources load correctly
4. Test navigation within the CTF app
5. Confirm no 404 errors for static assets

## 🔍 Troubleshooting

### Common Issues

#### 1. Resources Not Loading
**Problem**: CSS/JS files return 404
**Solution**: Check that `sub_filter` rules are working correctly

#### 2. CORS Errors
**Problem**: Browser blocks requests due to CORS
**Solution**: The proxy should handle this, but verify security headers are hidden

#### 3. Infinite Redirects
**Problem**: App keeps redirecting
**Solution**: Check that the CTF app doesn't have hardcoded redirects

#### 4. JavaScript Errors
**Problem**: JS can't find API endpoints
**Solution**: Ensure all API calls use relative paths or are rewritten

### Debug Commands

```bash
# Check nginx configuration
docker exec -it container_name nginx -t

# View nginx logs
docker exec -it container_name tail -f /var/log/nginx/error.log

# Test proxy directly
curl -H "Host: localhost" http://localhost/ctf/
```

## 🔧 Advanced Configuration

### Custom Proxy Headers
```nginx
# Add custom headers
proxy_set_header X-Custom-Header "value";
```

### SSL/TLS Support
```nginx
# For HTTPS
proxy_pass https://ctf.vercel.app/;
proxy_ssl_verify off;  # If needed
```

### Rate Limiting
```nginx
# Add rate limiting
limit_req_zone $binary_remote_addr zone=ctf:10m rate=10r/s;
location /ctf/ {
    limit_req zone=ctf burst=20 nodelay;
    # ... rest of config
}
```

### Caching
```nginx
# Enhanced caching
proxy_cache_path /tmp/nginx_cache levels=1:2 keys_zone=ctf_cache:10m max_size=10g inactive=60m use_temp_path=off;

location /ctf/ {
    proxy_cache ctf_cache;
    proxy_cache_use_stale error timeout http_500 http_502 http_503 http_504;
    proxy_cache_valid 200 1h;
    proxy_cache_valid 404 1m;
    # ... rest of config
}
```

## 📊 Performance Considerations

### Caching Strategy
- **Static Assets**: 1 year cache
- **HTML Pages**: 1 hour cache
- **Proxy Responses**: 1 hour cache for 200, 1 minute for 404

### Compression
- Gzip compression is enabled for all text-based responses
- Compression level is set to 6 (balanced)

### Security
- Security headers are hidden to prevent conflicts
- Original site's security is maintained
- No sensitive data is exposed

## 🔄 Alternative Approaches

### 1. Subdomain Approach
Instead of `/ctf`, use `ctf.yourdomain.com`:
```nginx
server {
    listen 80;
    server_name ctf.yourdomain.com;
    location / {
        proxy_pass https://ctf.vercel.app/;
        # ... proxy config
    }
}
```

### 2. Application-Level Rewriting
Modify the CTF application to support subdirectory deployment:
- Update all absolute paths to be relative
- Configure the app to run under `/ctf`
- Update API endpoints

### 3. CDN-Level Rewriting
Use a CDN like Cloudflare to handle path rewriting:
- Configure URL rewriting rules
- Use Cloudflare Workers for complex transformations

## 📚 References

- [Nginx Sub Filter Module](http://nginx.org/en/docs/http/ngx_http_sub_module.html)
- [Nginx Proxy Module](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)
- [Reverse Proxy Best Practices](https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass)

---

**Last Updated**: $(date)
**Configuration Version**: 1.0.0 