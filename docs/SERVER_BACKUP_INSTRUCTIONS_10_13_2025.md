# MRDBID Server Restoration Guide
**Last Updated: October 13, 2025**

## Critical Information

### Git Repository
- **Current Commit**: `f3adad1` - "hostinger db tables populated with scripts - email sending online"
- **Branch**: `main`
- **Deployment Method**: Capistrano (NOT Docker/Kamal)

### VPS Server Details
- **IP Address**: `85.31.233.192`
- **SSH User**: `root`
- **Application Path**: `/opt/mrdbid`
- **Puma Socket**: `unix:///opt/mrdbid/shared/tmp/sockets/puma.sock`

### Critical Files on Server

#### 1. Production Credentials
- **Location**: `/opt/mrdbid/shared/config/credentials/`
- **Files**:
  - `production.key` (32 bytes, permissions: 600)
  - `production.yml.enc` (928 bytes, permissions: 644)
- **Encryption Key**: `ed125d4dcb62fe61fea5ab987cb6e30b`
- **Symlink**: `/opt/mrdbid/current/config/credentials` → `/opt/mrdbid/shared/config/credentials`

#### 2. Environment Files
- `/opt/mrdbid/shared/.env`
- `/opt/mrdbid/shared/.env.production`

#### 3. Database Configuration
- **Database**: MySQL
- **Name**: `mrdbid_production`
- **User**: `mrdbid_user`
- **Password**: `uR!TxC4avEWp`
- **Host**: `127.0.0.1`

### Email Configuration (Hostinger SMTP)

```yaml
SMTP Server: smtp.hostinger.com
Port: 587
Encryption: STARTTLS

Accounts:
1. contact@mrdbid.com
   Password: 4NJ%wA~ktxhk@W?

2. webmaster@mrdbid.com
   Password: 6:XMXYr'kQ@}Q*v

3. will@mrdbid.com
   Password: D&)T;?xi7AD&8@+
```

## Backup Critical Server Files

### From Your Local Machine
```bash
# Backup production credentials
scp root@85.31.233.192:/opt/mrdbid/shared/config/credentials/production.key ~/mrdbid_backup/
scp root@85.31.233.192:/opt/mrdbid/shared/config/credentials/production.yml.enc ~/mrdbid_backup/

# Backup environment files
scp root@85.31.233.192:/opt/mrdbid/shared/.env ~/mrdbid_backup/
scp root@85.31.233.192:/opt/mrdbid/shared/.env.production ~/mrdbid_backup/

# Backup database
ssh root@85.31.233.192 "mysqldump -u mrdbid_user -p'uR!TxC4avEWp' mrdbid_production > /tmp/mrdbid_backup.sql"
scp root@85.31.233.192:/tmp/mrdbid_backup.sql ~/mrdbid_backup/
```

### On the Server
```bash
ssh root@85.31.233.192

# Create backup directory
mkdir -p /root/mrdbid_backup_$(date +%Y%m%d)

# Backup critical files
cp -r /opt/mrdbid/shared/config/credentials /root/mrdbid_backup_$(date +%Y%m%d)/
cp /opt/mrdbid/shared/.env* /root/mrdbid_backup_$(date +%Y%m%d)/
mysqldump -u mrdbid_user -p'uR!TxC4avEWp' mrdbid_production > /root/mrdbid_backup_$(date +%Y%m%d)/database.sql

# List backup
ls -lah /root/mrdbid_backup_$(date +%Y%m%d)/
```

## Complete Restoration Steps

### 1. Restore Code from Git
```bash
cd /Users/wrj/Documents/www/public_html/mrdbid
git fetch origin
git checkout 44560fe
```

### 2. Restore Production Credentials
```bash
# Upload from local backup
scp ~/mrdbid_backup/production.key root@85.31.233.192:/opt/mrdbid/shared/config/credentials/
scp ~/mrdbid_backup/production.yml.enc root@85.31.233.192:/opt/mrdbid/shared/config/credentials/

# Set correct permissions
ssh root@85.31.233.192 "chmod 600 /opt/mrdbid/shared/config/credentials/production.key"
ssh root@85.31.233.192 "chmod 644 /opt/mrdbid/shared/config/credentials/production.yml.enc"
```

### 3. Verify Credentials Symlink
```bash
ssh root@85.31.233.192
cd /opt/mrdbid/current/config
ls -la credentials
# Should show: credentials -> /opt/mrdbid/shared/config/credentials

# If missing, create it:
ln -s /opt/mrdbid/shared/config/credentials credentials
```

### 4. Restore Database
```bash
ssh root@85.31.233.192
mysql -u mrdbid_user -p'uR!TxC4avEWp' mrdbid_production < /root/mrdbid_backup_YYYYMMDD/database.sql
```

### 5. Deploy Application
```bash
cd /Users/wrj/Documents/www/public_html/mrdbid
cap production deploy
```

### 6. Restart Puma
```bash
ssh root@85.31.233.192
kill -SIGUSR2 $(cat /opt/mrdbid/shared/tmp/pids/puma.pid)
```

### 7. Verify Everything Works
```bash
# Test SMTP credentials
ssh root@85.31.233.192
cd /opt/mrdbid/current
RAILS_ENV=production bundle exec rails runner "puts Rails.application.credentials.dig(:smtp, :address)"
# Should output: smtp.hostinger.com

# Test email sending
RAILS_ENV=production bundle exec rails runner "
user = User.last
Devise::Mailer.confirmation_instructions(user, user.confirmation_token).deliver_now
puts 'Email sent successfully'
"
```

## Quick Health Check Commands

```bash
# Check Puma is running
ssh root@85.31.233.192 "ps aux | grep puma | grep -v grep"

# Check credentials exist
ssh root@85.31.233.192 "ls -la /opt/mrdbid/shared/config/credentials/"

# Check symlink
ssh root@85.31.233.192 "ls -la /opt/mrdbid/current/config/credentials"

# View recent logs
ssh root@85.31.233.192 "tail -50 /opt/mrdbid/shared/log/puma_stdout.log"

# Test website
curl -I https://mrdbid.com
```

## Capistrano Configuration

Key settings in `config/deploy.rb`:
- Application path: `/opt/mrdbid`
- Deploy user: `root`
- Repository: `https://github.com/mrdbidwill/mrdbid.git`
- Branch: `main`
- Puma bind: `unix:///opt/mrdbid/shared/tmp/sockets/puma.sock`

## Important Notes

1. **Never commit** the `production.key` file to git
2. **Always backup** credentials before making changes
3. The credentials symlink is critical - deployment won't work without it
4. SMTP authentication requires the EXACT password (special characters matter)
5. Database backups should be done regularly (not just when making changes)

## Routine Deployment (Minor Changes/Typo Fixes)

### From Local Machine:

```bash
# 1. Make your changes locally
# 2. Test locally if needed
# 3. Commit changes
git add .
git commit -m "Fix typo in XYZ"
git push origin main

# 4. Deploy to production
cap production deploy
```

That's it! Capistrano will:
- Pull latest code from Git
- Install any new gems
- Precompile assets
- Run migrations (if any)
- Restart Puma gracefully

### Manual Server Restart (if needed):

```bash
ssh root@85.31.233.192
kill -SIGUSR2 $(cat /opt/mrdbid/shared/tmp/pids/puma.pid)
```

## Server Maintenance

### Purge Old MySQL Binary Logs (Run Monthly):

```bash
ssh root@85.31.233.192
sudo mysql -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);"
```

### Clean Old Docker Images (if Docker was used):

```bash
ssh root@85.31.233.192
sudo docker system prune -a --volumes
```

### Check Disk Usage:

```bash
ssh root@85.31.233.192
df -h
sudo du -sh /var/lib/mysql
sudo du -sh /opt/mrdbid
```

---
**Created**: October 12, 2025
**Updated**: October 13, 2025
**Status**: ✅ WORKING - Production site operational
**Deployment**: Capistrano to `/opt/mrdbid`
