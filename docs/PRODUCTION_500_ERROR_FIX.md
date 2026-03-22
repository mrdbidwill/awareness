# Production 500 Error Fix - Deployment Guide

**Date:** 2025-10-31
**Issue:** Internal Server Error (500) on production after updates
**Root Cause:** Queue adapter misconfiguration (`:async` instead of `:solid_queue`)

---

## ⚠️ Critical Fix Applied

**Changed:** `config/environments/production.rb` line 82
**From:** `config.active_job.queue_adapter = :async`
**To:** `config.active_job.queue_adapter = :solid_queue`

**Why This Matters:**
- Production uses Solid Queue (database-backed job queue)
- The `mrdbid_production_queue` database exists on production server
- Using `:async` (in-memory) while trying to connect to queue DB causes initialization failures
- Result: 500 errors on ALL pages

---

## Files Modified

### 1. `config/environments/production.rb`
- **Line 82:** Changed queue adapter from `:async` to `:solid_queue`
- **Lines 54-83:** Added comprehensive documentation explaining:
  - Required databases (queue, cache, cable)
  - Symptoms of misconfiguration
  - Verification commands
  - Troubleshooting steps
  - **CRITICAL warnings not to change back to :async**

### 2. `app/controllers/mushrooms_controller.rb`
- **Lines 68-73:** Removed 4 duplicate database queries (performance issue)
- **Lines 1-22:** Added controller overview documentation
- **Lines 61-90:** Documented update action with security/performance notes
- **Lines 124-178:** Added comprehensive private method documentation

### 3. `config/puma.rb`
- **Lines 1-22:** Added overview of Puma configuration
- **Lines 24-37:** Documented threading configuration and DB pool requirements
- **Lines 41-60:** Explained production vs development setup
- **Lines 62-90:** Documented plugins with enabling instructions

### 4. `config/puma.service`
- **Lines 1-26:** Added systemd service documentation
- **Lines 37-60:** Documented environment variables and .env file usage
- **Lines 62-78:** Explained process management
- **Lines 80-98:** Documented restart policy
- **Lines 100-115:** Explained logging configuration

---

## Deployment Instructions

### Step 1: Deploy Code Changes
```bash
# From local machine
cap production deploy
```

This will:
1. Push code changes to production server
2. Run any pending migrations
3. Precompile assets
4. **Restart Puma automatically** (see config/deploy.rb line 56)

### Step 2: Verify Puma Restart
```bash
# SSH to production server
ssh root@85.31.233.192

# Check Puma service status
sudo systemctl status puma-mrdbid.service

# Should show:
# Active: active (running)
# Main PID: [some number]
```

### Step 3: Update Systemd Service File (Important!)
The `puma.service` file has been updated with extensive documentation. To apply:

```bash
# On production server
sudo cp /opt/mrdbid/current/config/puma.service /etc/systemd/system/puma-mrdbid.service
sudo systemctl daemon-reload
sudo systemctl restart puma-mrdbid.service
```

### Step 4: Verify Fix
```bash
# Check logs for errors
sudo journalctl -xeu puma-mrdbid.service -n 50

# Or check Puma error log
tail -f /opt/mrdbid/shared/log/puma_stderr.log

# Should see NO "ActiveRecord::ConnectionNotEstablished" errors
```

### Step 5: Test Website
1. Visit https://mrdbid.com
2. Login with your credentials
3. Navigate to https://mrdbid.com/mushrooms
4. **Should see mushrooms list (not 500 error)**

---

## What Was Wrong?

### The Problem
```ruby
# WRONG (was causing 500 errors)
config.active_job.queue_adapter = :async
config.solid_queue.connects_to = { database: { writing: :queue } }
```

This configuration is contradictory:
- Line 1: "Use in-memory queue (no database)"
- Line 2: "Connect to queue database"

When Rails boots, it tries to:
1. Initialize Active Job with `:async` adapter
2. Configure Solid Queue database connection
3. Fails because `:async` doesn't use database
4. Initialization failure → 500 error on all requests

### The Fix
```ruby
# CORRECT (what we changed it to)
config.active_job.queue_adapter = :solid_queue
config.solid_queue.connects_to = { database: { writing: :queue } }
```

Now both lines agree:
- Line 1: "Use Solid Queue (database-backed)"
- Line 2: "Here's the database to use"

---

## Why This Keeps Happening (And How We're Fixing It)

### Past Pattern
1. Fix one issue → deploy
2. New issue appears (or old issue reappears)
3. Fix without documenting → repeat

### New Approach (This Fix)
**Every change includes extensive comments explaining:**
- **What** the code does
- **Why** it's configured this way
- **What happens** if you change it
- **How to troubleshoot** if something breaks
- **Critical warnings** with ⚠️ symbols

**Goal:** Next time there's an issue, read the comments FIRST before changing code.

---

## Documentation Added

### For Future You (or Any Developer)

1. **config/environments/production.rb (lines 54-83)**
   - Explains Solid Queue setup
   - Lists required databases
   - Shows verification commands
   - **Warns against changing queue adapter**

2. **config/puma.rb (lines 1-90)**
   - Explains threading vs database pool
   - Documents production vs development
   - Shows how to enable Solid Queue in Puma
   - Links to troubleshooting commands

3. **config/puma.service (lines 1-118)**
   - Complete systemd service documentation
   - Environment variable guide
   - Restart policy explanation
   - Log locations and viewing commands

4. **app/controllers/mushrooms_controller.rb (lines 1-178)**
   - Controller purpose and flow
   - Security explanations
   - Performance notes (eager loading)
   - **Warns against duplicate queries**

---

## Troubleshooting Commands (For Future Reference)

### Check Service Status
```bash
sudo systemctl status puma-mrdbid.service
```

### View Recent Logs
```bash
sudo journalctl -xeu puma-mrdbid.service -n 50
tail -n 50 /opt/mrdbid/shared/log/puma_stderr.log
```

## 2026-03-01 Addendum (Not a 500 Error)

A separate incident caused CPU spikes and slow response times:
**Root cause:** duplicate `puma.service` running alongside `puma-mrdbid.service`, both binding `/opt/mrdbid/shared/tmp/sockets/puma.sock`.

**Fix:**
```bash
sudo systemctl stop puma.service
sudo systemctl disable puma.service
sudo systemctl mask --force puma.service
```

This is unrelated to the 500 error issue above, but it can make the site feel unusably slow.

### Additional Logs
```bash
# Systemd logs (last 50 lines)
sudo journalctl -xeu puma-mrdbid.service -n 50

# Puma stderr (errors)
tail -50 /opt/mrdbid/shared/log/puma_stderr.log

# Puma stdout (info)
tail -50 /opt/mrdbid/shared/log/puma_stdout.log

# Rails production log
tail -50 /opt/mrdbid/shared/log/production.log
```

### Restart Puma
```bash
# Via systemd (preferred)
sudo systemctl restart puma-mrdbid.service

# Via Capistrano (from local machine)
cap production systemd_puma:restart
```

### Verify Database Setup
```bash
# Check databases exist
mysql -u root -p -e "SHOW DATABASES LIKE 'mrdbid_production_%';"

# Should show:
# mrdbid_production_cache
# mrdbid_production_cable
# mrdbid_production_queue

# Check queue tables exist
mysql -u root -p mrdbid_production_queue -e "SHOW TABLES;"

# Should show 13 solid_queue_* tables
```

### Check Environment Variables
```bash
# View .env file (contains DB credentials, etc.)
cat /opt/mrdbid/shared/.env

# Should contain:
# MYSQL_DATABASE=mrdbid_production
# MYSQL_USER=...
# MYSQL_PASSWORD=...
# RAILS_MASTER_KEY=...
# APP_HOST=mrdbid.com
```

---

## Prevention Checklist

Before making ANY configuration changes in production:

1. ✅ Read existing comments in the file
2. ✅ Understand what each line does
3. ✅ Check for ⚠️ CRITICAL warnings
4. ✅ Test changes in development first
5. ✅ Document WHY you're making the change
6. ✅ Add comments explaining the change
7. ✅ Deploy via Capistrano (not manual edits)
8. ✅ Monitor logs after deployment

---

## Related Configuration Files

These files work together - changing one may require changing others:

- `config/environments/production.rb` - Rails production config
- `config/database.yml` - Database connections (queue, cache, cable)
- `config/puma.rb` - Puma web server config
- `config/puma.service` - Systemd service definition
- `config/deploy.rb` - Capistrano deployment config
- `/opt/mrdbid/shared/.env` - Environment variables (ON SERVER)

**Rule:** If you change queue adapter, you MUST verify database.yml has corresponding database definition.

---

## Summary

### What We Did
1. ✅ Fixed queue adapter configuration (`:async` → `:solid_queue`)
2. ✅ Removed 4 duplicate database queries
3. ✅ Added 200+ lines of documentation
4. ✅ Explained WHY each configuration exists
5. ✅ Added troubleshooting commands
6. ✅ Warned against future changes

### Expected Result
- ✅ Production website loads without 500 errors
- ✅ Mushrooms page displays correctly
- ✅ Background jobs work (if/when used)
- ✅ Future developers understand the configuration

### If 500 Error Persists
1. Check logs: `sudo journalctl -xeu puma-mrdbid.service -n 100`
2. Read the comments in production.rb (lines 54-83)
3. Verify databases: `mysql -e "SHOW DATABASES LIKE 'mrdbid_production_%';"`
4. Check queue adapter: `grep "queue_adapter" config/environments/production.rb`
5. Should see: `config.active_job.queue_adapter = :solid_queue`

---

**Documentation Author:** Claude (AI Assistant)
**Date:** October 31, 2025
**Purpose:** Prevent circular debugging by documenting the WHY, not just the WHAT
