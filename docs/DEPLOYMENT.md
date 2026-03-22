# Capistrano Deployment Guide

## Overview

This application deploys to a Hostinger VPS using Capistrano. The deployment is automated and handles code updates, asset compilation, and database migrations.

**Auto-deploy status:** CI/CD auto-deploy is intentionally **disabled** (GitHub Actions produced noisy false errors). Current deployment is manual via Capistrano.

## Server Setup

### Prerequisites on VPS (root@85.31.233.192)

1. **Ruby via rbenv**
   ```bash
   # Install rbenv
   git clone https://github.com/rbenv/rbenv.git ~/.rbenv
   git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

   # Add to ~/.bashrc
   echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
   echo 'eval "$(rbenv init -)"' >> ~/.bashrc
   source ~/.bashrc

   # Install Ruby 3.4.3
   rbenv install 3.4.3
   rbenv global 3.4.3
   ```

2. **Node.js** (for asset compilation)
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   apt-get install -y nodejs
   ```

3. **MySQL 8.0**
   ```bash
   apt-get install -y mysql-server mysql-client libmysqlclient-dev

   # Secure MySQL
   mysql_secure_installation

   # Create database and user
   mysql -u root -p
   CREATE DATABASE mrdbid_production;
   CREATE USER 'mrdbid'@'localhost' IDENTIFIED BY 'your_secure_password';
   GRANT ALL PRIVILEGES ON mrdbid_production.* TO 'mrdbid'@'localhost';
   FLUSH PRIVILEGES;
   ```

4. **Nginx**
   ```bash
   apt-get install -y nginx

   # Configuration will be in /etc/nginx/sites-available/mrdbid
   ```

5. **Create deployment directory**
   ```bash
   mkdir -p /opt/mrdbid
   chown root:root /opt/mrdbid
   ```

## Local Setup

### SSH Access

Preferred access is via the Hostinger terminal. For direct SSH, ensure you have key access configured:
```bash
ssh root@85.31.233.192
```

Capistrano deploys run as the `deploy` user (see `config/deploy/production.rb`).

### Credentials

1. **Master Key**: Must exist in `/opt/mrdbid/shared/config/master.key` on server
2. **Credentials**: Must exist in `/opt/mrdbid/shared/config/credentials.yml.enc` on server

Copy these files manually on first deployment:
```bash
scp config/master.key root@85.31.233.192:/opt/mrdbid/shared/config/
scp config/credentials.yml.enc root@85.31.233.192:/opt/mrdbid/shared/config/
```

## Deployment

### First Deployment

```bash
# Install Capistrano
bundle install

# Set up directory structure on server
cap production deploy:check

# Deploy
cap production deploy
```

### Subsequent Deployments

```bash
cap production deploy
```

This automatically restarts:
1. `puma-mrdbid.service`
2. `solid-queue-mrdbid.service` (if installed)

## Production Env Flags (R2 + AdSense)

Ensure these are set in `/opt/mrdbid/shared/.env` before deploying:

```bash
ACTIVE_STORAGE_SERVICE=r2
R2_BUCKET=your_bucket
R2_ENDPOINT=https://<accountid>.r2.cloudflarestorage.com
R2_REGION=auto
R2_ACCESS_KEY_ID=your_access_key
R2_SECRET_ACCESS_KEY=your_secret_key
R2_PUBLIC_BASE_URL=https://images.mrdbid.com

ADSENSE_ENABLED=false
ADSENSE_CLIENT_ID=ca-pub-...
```

### Systemd Safeguards (Required)

Capistrano now includes a guard that fails the deploy early if legacy units are not masked:
1. `puma.service`
2. `puma_auto_glossary.service`

Verification:
```bash
systemctl is-enabled puma.service
systemctl is-enabled puma_auto_glossary.service
# Expect: masked or not-found
```

### Database Migrations

Migrations run automatically during deployment. To disable:
```bash
# Remove from Capfile: require "capistrano/rails/migrations"
```

To run migrations manually:
```bash
cap production deploy:migrate
```

### Manual Backfill Scripts

After deployment, you may need to run the backfill scripts manually:

```bash
ssh root@85.31.233.192
cd /opt/mrdbid/current

# Load mb_lists data
mysql -u mrdbid -p mrdbid_production < db/scripts/mblist/import_mb_lists.sql

# Backfill genera
mysql -u mrdbid -p mrdbid_production < db/scripts/mblist/backfill_genera_table_from_mblist.sql

# Backfill species
mysql -u mrdbid -p mrdbid_production < db/scripts/mblist/backfill_species_table_from_mblist.sql
```

## Capistrano Tasks

### View Available Tasks
```bash
cap -T
```

### Common Tasks

- `cap production deploy` - Full deployment
- `cap production deploy:restart` - Restart Puma
- `cap production puma:start` - Start Puma
- `cap production puma:stop` - Stop Puma
- `cap production puma:status` - Check Puma status
- `cap production logs:tail` - Tail production logs

## Failure Notifications (Recommended)

Puma units call `notify-on-failure@%n.service` on failure. Ensure these exist on the server:
1. `/etc/systemd/system/notify-on-failure@.service`
2. `/usr/local/bin/systemd_notify_failure.sh`
3. `/etc/systemd/system/notify-on-failure.env` with `EMAIL_TO` and `EMAIL_FROM`

Test:
```bash
sudo systemctl start notify-on-failure@puma-mrdbid.service
```

## Monitoring (Recommended)

Use a lightweight endpoint for uptime monitoring:
- `https://mrdbid.com/health`

This maps to Rails' health controller and should return HTTP 200 when the app is healthy.

## Directory Structure on Server

```
/opt/mrdbid/
├── current -> /opt/mrdbid/releases/20251011120000
├── releases/
│   ├── 20251011120000/
│   ├── 20251011110000/
│   └── ...
├── shared/
│   ├── config/
│   │   ├── master.key
│   │   └── credentials.yml.enc
│   ├── log/
│   ├── tmp/
│   │   ├── pids/
│   │   ├── cache/
│   │   └── sockets/
│   ├── public/
│   │   ├── system/
│   │   └── uploads/
│   └── storage/
└── repo/ (git repository cache)
```

## Nginx Configuration

Create `/etc/nginx/sites-available/mrdbid`:

```nginx
upstream puma {
  server unix:///opt/mrdbid/shared/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name yourdomain.com www.yourdomain.com;

  # Redirect HTTP to HTTPS (uncomment when SSL is set up)
  # return 301 https://$server_name$request_uri;
}

server {
  # listen 443 ssl http2;
  listen 80;  # Change to 443 when SSL is set up
  server_name yourdomain.com www.yourdomain.com;

  root /opt/mrdbid/current/public;
  access_log /opt/mrdbid/shared/log/nginx_access.log;
  error_log /opt/mrdbid/shared/log/nginx_error.log info;

  # SSL Configuration (uncomment when ready)
  # ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
  # ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  try_files $uri/index.html $uri @puma;

  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://puma;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

Enable the site:
```bash
ln -s /etc/nginx/sites-available/mrdbid /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

## SSL Setup (Optional but Recommended)

```bash
# Install certbot
apt-get install -y certbot python3-certbot-nginx

# Get certificate
certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal is set up automatically via cron
```

## Migration Notes

### Foreign Key Constraints

Migrations are already ordered correctly to respect foreign key dependencies. If you encounter issues during migration:

1. Check the error message for which foreign key is failing
2. Ensure parent tables exist before child tables
3. The migration order has been verified and should work correctly

### Backfill Scripts

The backfill scripts in `db/scripts/mblist/` use `INSERT IGNORE` to prevent duplicate entries:
- `backfill_genera_table_from_mblist.sql` - Safe to run multiple times
- `backfill_species_table_from_mblist.sql` - Safe to run multiple times

## Troubleshooting

### Deployment Fails

```bash
# Check Capistrano output for errors
# Common issues:
# - SSH access problems
# - Missing master.key on server
# - Database connection issues
# - Asset compilation failures
```

### Puma Won't Start

```bash
# Check logs
ssh root@85.31.233.192
cd /opt/mrdbid/current
tail -f /opt/mrdbid/shared/log/puma_error.log

# Restart manually
cap production puma:restart
```

### Database Connection Errors

```bash
# Verify database credentials in Rails credentials
ssh root@85.31.233.192
cd /opt/mrdbid/current
RAILS_ENV=production bin/rails runner "puts ActiveRecord::Base.connection.execute('SELECT 1').to_a"
```

### Assets Not Loading

```bash
# Recompile assets
ssh root@85.31.233.192
cd /opt/mrdbid/current
RAILS_ENV=production bin/rails assets:precompile
cap production deploy:restart
```

## Rollback

If a deployment fails, Capistrano can rollback to the previous release:

```bash
cap production deploy:rollback
```

This switches the `current` symlink back to the previous release directory.

## Version Info

- Ruby: 3.4.3
- Rails: 8.0+
- MySQL: 8.0
- Nginx: Latest stable
- Puma: Managed by Capistrano
