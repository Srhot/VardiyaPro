# VardiyaPro - Production Deployment Guide

This guide provides comprehensive instructions for deploying VardiyaPro to production environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Variables](#environment-variables)
- [Database Setup](#database-setup)
- [Docker Deployment](#docker-deployment)
- [Manual Deployment](#manual-deployment)
- [Security Checklist](#security-checklist)
- [Monitoring & Maintenance](#monitoring--maintenance)

## Prerequisites

### System Requirements

- **Ruby**: 3.3.9
- **PostgreSQL**: 15+
- **RAM**: Minimum 2GB (recommended 4GB+)
- **CPU**: 2+ cores recommended
- **Storage**: Minimum 10GB free space

### Required Services

- PostgreSQL 15 database server
- Redis (optional, for ActionCable/caching)
- SMTP server (for email notifications)

## Environment Variables

Create a `.env` file with the following variables:

```bash
# Database Configuration
DATABASE_HOST=your-postgres-host
DATABASE_USER=vardiyapro
DATABASE_PASSWORD=your-secure-password
DATABASE_NAME=vardiyapro_production
DB_POOL=5

# JWT Configuration (CHANGE THESE!)
JWT_SECRET=your-very-long-secure-random-secret-key-min-32-chars
JWT_EXPIRY_HOURS=24

# Rails Configuration
RAILS_ENV=production
RAILS_MAX_THREADS=5
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Secret Key Base (Generate with: rails secret)
SECRET_KEY_BASE=your-rails-secret-key-base

# Server Configuration
PORT=3000
RAILS_HOSTNAME=your-domain.com

# Email Configuration (ActionMailer)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=your-domain.com
SMTP_USERNAME=your-email@example.com
SMTP_PASSWORD=your-smtp-password
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
EMAIL_FROM=noreply@your-domain.com

# Frontend URL (for CORS)
FRONTEND_URL=https://your-frontend-domain.com

# Optional: Redis
REDIS_URL=redis://localhost:6379/0
```

### Generate Secrets

```bash
# Generate JWT secret (minimum 32 characters)
openssl rand -hex 32

# Generate Rails secret key base
bundle exec rails secret
```

## Database Setup

### 1. Create PostgreSQL User and Database

```sql
-- Connect to PostgreSQL as superuser
sudo -u postgres psql

-- Create user
CREATE USER vardiyapro WITH PASSWORD 'your-secure-password';

-- Create database
CREATE DATABASE vardiyapro_production OWNER vardiyapro;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE vardiyapro_production TO vardiyapro;

-- Exit
\q
```

### 2. Configure PostgreSQL for Remote Access (if needed)

Edit `/etc/postgresql/15/main/postgresql.conf`:
```
listen_addresses = '*'
```

Edit `/etc/postgresql/15/main/pg_hba.conf`:
```
host    vardiyapro_production    vardiyapro    0.0.0.0/0    md5
```

Restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

## Docker Deployment

### Using Docker Compose (Recommended)

1. **Create production docker-compose file:**

```yaml
# docker-compose.production.yml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: ${DATABASE_USER}
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD}
      POSTGRES_DB: ${DATABASE_NAME}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DATABASE_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      DATABASE_HOST: db
      DATABASE_USER: ${DATABASE_USER}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD}
      DATABASE_NAME: ${DATABASE_NAME}
      RAILS_ENV: production
      JWT_SECRET: ${JWT_SECRET}
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    command: ./bin/rails server -b 0.0.0.0

volumes:
  postgres_data:
```

2. **Deploy:**

```bash
# Build images
docker-compose -f docker-compose.production.yml build

# Run database migrations
docker-compose -f docker-compose.production.yml run --rm web rails db:migrate

# Seed initial data (if needed)
docker-compose -f docker-compose.production.yml run --rm web rails db:seed

# Start services
docker-compose -f docker-compose.production.yml up -d

# Check logs
docker-compose -f docker-compose.production.yml logs -f web
```

### Single Docker Container

```bash
# Build image
docker build -t vardiyapro:latest .

# Run container
docker run -d \
  --name vardiyapro \
  -p 3000:3000 \
  -e DATABASE_HOST=your-db-host \
  -e DATABASE_USER=vardiyapro \
  -e DATABASE_PASSWORD=your-password \
  -e DATABASE_NAME=vardiyapro_production \
  -e RAILS_ENV=production \
  -e JWT_SECRET=your-jwt-secret \
  -e SECRET_KEY_BASE=your-secret-key-base \
  vardiyapro:latest
```

## Manual Deployment

### 1. Install Dependencies

```bash
# Install Ruby 3.3.9 (using rbenv)
rbenv install 3.3.9
rbenv global 3.3.9

# Install bundler
gem install bundler

# Install gems
bundle config set --local deployment 'true'
bundle config set --local without 'development test'
bundle install
```

### 2. Prepare Application

```bash
# Set environment
export RAILS_ENV=production

# Precompile assets (if using assets)
bundle exec rails assets:precompile

# Run migrations
bundle exec rails db:migrate

# Seed database (first time only)
bundle exec rails db:seed
```

### 3. Start Server

#### Using Puma (Recommended)

```bash
# Start Puma
bundle exec puma -C config/puma.rb
```

#### Using systemd (for automatic restart)

Create `/etc/systemd/system/vardiyapro.service`:

```ini
[Unit]
Description=VardiyaPro Rails Application
After=network.target postgresql.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/vardiyapro
Environment=RAILS_ENV=production
EnvironmentFile=/home/deploy/vardiyapro/.env
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable vardiyapro
sudo systemctl start vardiyapro
sudo systemctl status vardiyapro
```

## Reverse Proxy Setup (Nginx)

Create `/etc/nginx/sites-available/vardiyapro`:

```nginx
upstream vardiyapro {
  server 127.0.0.1:3000 fail_timeout=0;
}

server {
  listen 80;
  server_name your-domain.com;

  # Redirect to HTTPS
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl http2;
  server_name your-domain.com;

  # SSL certificates (use Let's Encrypt)
  ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

  root /home/deploy/vardiyapro/public;

  location / {
    proxy_pass http://vardiyapro;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

Enable and restart:
```bash
sudo ln -s /etc/nginx/sites-available/vardiyapro /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Security Checklist

- [ ] Change all default passwords
- [ ] Generate new JWT_SECRET (min 32 chars)
- [ ] Generate new SECRET_KEY_BASE
- [ ] Enable HTTPS/SSL certificates
- [ ] Configure firewall (allow only 80, 443, 22)
- [ ] Disable PostgreSQL remote access (if not needed)
- [ ] Set up database backups
- [ ] Configure fail2ban
- [ ] Enable Rails force_ssl in production
- [ ] Set up monitoring/logging
- [ ] Configure CORS properly
- [ ] Rotate credentials regularly

## Database Backups

### Automated Daily Backup Script

Create `/home/deploy/backup-db.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/home/deploy/backups"
DATE=$(date +%Y%m%d_%H%M%S)
FILENAME="vardiyapro_${DATE}.sql"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
pg_dump -h localhost -U vardiyapro vardiyapro_production > "${BACKUP_DIR}/${FILENAME}"

# Compress
gzip "${BACKUP_DIR}/${FILENAME}"

# Keep only last 30 days
find $BACKUP_DIR -name "vardiyapro_*.sql.gz" -mtime +30 -delete

echo "Backup completed: ${FILENAME}.gz"
```

Add to crontab:
```bash
0 2 * * * /home/deploy/backup-db.sh
```

## Monitoring & Maintenance

### Health Check Endpoint

```bash
curl https://your-domain.com/up
```

### Application Logs

```bash
# Docker
docker-compose logs -f web

# Systemd
sudo journalctl -u vardiyapro -f

# Direct file
tail -f log/production.log
```

### Database Maintenance

```bash
# Vacuum database
psql -U vardiyapro vardiyapro_production -c "VACUUM ANALYZE;"

# Check database size
psql -U vardiyapro vardiyapro_production -c "SELECT pg_size_pretty(pg_database_size('vardiyapro_production'));"
```

### Performance Monitoring

- Monitor response times
- Track database query performance
- Monitor memory/CPU usage
- Set up error tracking (Sentry, Rollbar)
- Use APM tools (New Relic, Datadog)

## Troubleshooting

### Common Issues

**Database connection failed:**
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Test connection
psql -h localhost -U vardiyapro vardiyapro_production

# Check logs
sudo tail -f /var/log/postgresql/postgresql-15-main.log
```

**Port already in use:**
```bash
# Find process
sudo lsof -i :3000

# Kill process
sudo kill -9 <PID>
```

**Permission errors:**
```bash
# Fix ownership
sudo chown -R deploy:deploy /home/deploy/vardiyapro

# Fix permissions
chmod +x bin/*
```

## Scaling Considerations

### Horizontal Scaling

- Deploy multiple app instances behind load balancer
- Use shared PostgreSQL database
- Configure session storage in Redis/database
- Use CDN for static assets

### Vertical Scaling

- Increase database connection pool
- Add more worker threads (RAILS_MAX_THREADS)
- Increase server resources (RAM/CPU)

## Support

For issues or questions:
- Check application logs
- Review GitHub issues
- Contact: support@vardiyapro.com

---

**Last Updated:** 2025-01-08
**Version:** 1.0.0
