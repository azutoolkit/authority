# SSL Certificates

Enable HTTPS for Authority.

## Overview

There are two approaches to enable HTTPS:

1. **Reverse proxy** (recommended) - Terminate SSL at Nginx/Traefik
2. **Direct SSL** - Authority handles SSL directly

## Option 1: Reverse Proxy (Recommended)

### Nginx with Let's Encrypt

Install Certbot:

```bash
sudo apt install certbot python3-certbot-nginx
```

Get certificate:

```bash
sudo certbot --nginx -d auth.example.com
```

Nginx configuration:

```nginx
server {
    listen 443 ssl http2;
    server_name auth.example.com;

    ssl_certificate /etc/letsencrypt/live/auth.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/auth.example.com/privkey.pem;

    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=63072000" always;

    location / {
        proxy_pass http://127.0.0.1:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name auth.example.com;
    return 301 https://$server_name$request_uri;
}
```

Update Authority configuration:

```bash
BASE_URL=https://auth.example.com
```

### Traefik with Let's Encrypt

```yaml
# traefik.yml
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"

certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@example.com
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web
```

Docker labels:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.authority.rule=Host(`auth.example.com`)"
  - "traefik.http.routers.authority.entrypoints=websecure"
  - "traefik.http.routers.authority.tls.certresolver=letsencrypt"
```

## Option 2: Direct SSL

Authority can handle SSL directly using environment variables.

### Generate Self-Signed Certificate (Development)

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout authority.key \
  -out authority.crt \
  -subj "/CN=localhost"
```

### Configure Authority

```bash
SSL_CERT=/path/to/authority.crt
SSL_KEY=/path/to/authority.key
BASE_URL=https://localhost:4000
```

### Using Let's Encrypt Certificates

```bash
SSL_CERT=/etc/letsencrypt/live/auth.example.com/fullchain.pem
SSL_KEY=/etc/letsencrypt/live/auth.example.com/privkey.pem
BASE_URL=https://auth.example.com
```

## Certificate Renewal

### Certbot Auto-Renewal

Certbot sets up automatic renewal. Test with:

```bash
sudo certbot renew --dry-run
```

### Manual Renewal Hook

Create renewal hook to reload Authority:

```bash
# /etc/letsencrypt/renewal-hooks/post/reload-authority.sh
#!/bin/bash
docker-compose -f /path/to/docker-compose.yml restart authority
```

## Security Headers

Add security headers in your reverse proxy:

```nginx
# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'" always;
```

## Verify SSL Configuration

Test your SSL setup:

```bash
# Check certificate
openssl s_client -connect auth.example.com:443 -servername auth.example.com

# SSL Labs test
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=auth.example.com
```

## Troubleshooting

### Certificate chain incomplete

Include the full chain:

```bash
SSL_CERT=/path/to/fullchain.pem  # Not just cert.pem
```

### Permission denied

Ensure Authority can read certificates:

```bash
chmod 644 authority.crt
chmod 600 authority.key
```

### Mixed content warnings

Ensure `BASE_URL` uses `https://`:

```bash
BASE_URL=https://auth.example.com
```

## Next Steps

- [Environment Variables](environment-variables.md) - All configuration options
- [Docker Installation](../installation/docker.md) - Production setup
- [Enable MFA](../security/enable-mfa.md) - Additional security
