# Production 500 Error - ACTUAL Root Cause & Fix

**Date:** 2025-10-31 (Multiple investigations)
**Issue:** Internal Server Error (500) on production at https://mrdbid.com/mushrooms
**Root Cause:** Solid Queue Puma plugin + Rails 8 strict_loading incompatibility

---

## Timeline of Investigation

### Round 1: Initial Diagnosis (WRONG)
**Suspected:** Queue adapter misconfiguration (`:async` instead of `:solid_queue`)
**Action:** Changed config/environments/production.rb line 82
**Result:** Fixed code, deployed, but **500 errors persisted**

### Round 2: Checked Production Logs
**Found:** `ActiveRecord::StrictLoadingViolationError` in `/opt/mrdbid/shared/log/puma_stderr.log`
**Error:** `SolidQueue::Process` marked for strict_loading, cannot lazy load `:supervisees`
**Discovery:** The queue adapter fix was correct, but plugin itself is crashing

### Round 3: Identified Actual Root Cause
**Found:** `/etc/systemd/system/puma-mrdbid.service` has `Environment="SOLID_QUEUE_IN_PUMA=1"`
**Problem:** Solid Queue 1.2.1 has a bug when running as Puma plugin with Rails 8
**Impact:** Plugin crashes during Puma boot, before any web requests are served

---

## The Actual Bug

### What's Happening

```
=== puma startup: 2025-10-31 14:49:57 +0000 ===
ActiveRecord::StrictLoadingViolationError:
`SolidQueue::Process` is marked for strict_loading.
The SolidQueue::Process association named `:supervisees` cannot be lazily loaded.
```

**Explanation:**
1. Puma starts and loads Rails application
2. Because `SOLID_QUEUE_IN_PUMA=1` is set, Puma plugin tries to start Solid Queue supervisor
3. Solid Queue's internal models (`SolidQueue::Process`) have `strict_loading` enabled
4. During shutdown/cleanup, it tries to lazy load `:supervisees` association
5. Rails 8's strict_loading feature raises error
6. Plugin crashes, Puma fails to fully initialize
7. Web requests get 500 errors because Puma isn't ready

### Why This Is Hard to Debug

- Error happens **during plugin initialization**, not during web requests
- Logs show the crash, but it's in Solid Queue internals
- The queue adapter configuration WAS wrong, masking the real issue
- Plugin is optional feature that most people don't enable

---

## THE FIX (Required on Production Server)

### Step-by-Step Instructions

**⚠️ CRITICAL: This fix must be done on the production server, not in code**

1. **SSH to production server:**
   ```bash
   ssh root@85.31.233.192
   ```

2. **Edit the systemd service file:**
   ```bash
   sudo nano /etc/systemd/system/puma-mrdbid.service
   ```

3. **Find this line** (should be around line 13-15):
   ```ini
   Environment="SOLID_QUEUE_IN_PUMA=1"
   ```

4. **Comment it out or delete it:**
   ```ini
   # Environment="SOLID_QUEUE_IN_PUMA=1"  # DISABLED: Bug with Rails 8 strict_loading
   ```

5. **Save and exit** (Ctrl+O, Enter, Ctrl+X in nano)

6. **Reload systemd configuration:**
   ```bash
   sudo systemctl daemon-reload
   ```

7. **Restart Puma:**
   ```bash
   sudo systemctl restart puma-mrdbid.service
   ```

8. **Verify Puma started successfully:**
   ```bash
   sudo systemctl status puma-mrdbid.service
   ```

   Should show:
   ```
   Active: active (running)
   ```

9. **Check for errors in logs:**
   ```bash
   tail -50 /opt/mrdbid/shared/log/puma_stderr.log
   ```

   Should NOT see `ActiveRecord::StrictLoadingViolationError`

10. **Test the website:**
    - Visit https://mrdbid.com/mushrooms
    - Should load without 500 error
    - Should show your mushrooms list

---

## What This Fix Does

### Before (Broken)
- `SOLID_QUEUE_IN_PUMA=1` environment variable set
- Puma tries to load Solid Queue plugin
- Plugin crashes on Rails 8 strict_loading bug
- Puma never fully starts
- All web requests get 500 errors

### After (Fixed)
- `SOLID_QUEUE_IN_PUMA` not set (or explicitly disabled)
- Puma does NOT load Solid Queue plugin
- Puma starts normally
- Web requests work fine
- Background jobs DON'T run (but you're not using them yet)

### What About Background Jobs?

**Current situation:** You have `:solid_queue` configured but plugin disabled
- Queue adapter is configured correctly (code level)
- Jobs will be queued to database
- But no worker process to execute them

**When you need background jobs later:**
- Use Option B from `SOLID_QUEUE_SETUP.md` (separate service)
- Or wait for Solid Queue bug fix and re-enable plugin

---

## Why Both Fixes Were Needed

### Fix #1: Queue Adapter (Code Level)
**File:** `config/environments/production.rb`
**Change:** `:async` → `:solid_queue`
**Why:** Tells Rails which queue system to use
**Status:** ✅ Done, committed, deployed

### Fix #2: Disable Plugin (Server Level)
**File:** `/etc/systemd/system/puma-mrdbid.service` (ON SERVER)
**Change:** Remove `Environment="SOLID_QUEUE_IN_PUMA=1"`
**Why:** Prevents buggy plugin from crashing Puma
**Status:** ⚠️  **MUST BE DONE MANUALLY ON SERVER**

Both are required:
- Without Fix #1: Wrong queue adapter causes initialization errors
- Without Fix #2: Plugin crashes Puma during boot

---

## Code Changes Already Deployed

These files were updated, committed, and deployed:

### 1. `config/environments/production.rb`
- Fixed queue adapter configuration
- Added 30 lines of documentation
- Explained Solid Queue setup and troubleshooting

### 2. `app/controllers/mushrooms_controller.rb`
- Removed 4 duplicate queries
- Added 70+ lines of documentation

### 3. `config/puma.rb`
- Added 90 lines of documentation
- **Added warnings about SOLID_QUEUE_IN_PUMA bug** (lines 76-84)

### 4. `config/puma.service`
- Added 60 lines of documentation
- Template for systemd service (not the actual server file)

### 5. `SOLID_QUEUE_SETUP.md`
- Documented the Rails 8 strict_loading bug
- Added Known Issues section
- Marked status as DISABLED DUE TO BUG

---

## Verification After Fix

Run these commands to verify the fix worked:

```bash
# On production server

# 1. Check Puma is running
sudo systemctl status puma-mrdbid.service
# Should show: Active: active (running)

# 2. Check logs for errors
tail -50 /opt/mrdbid/shared/log/puma_stderr.log
# Should NOT see StrictLoadingViolationError

# 3. Check process list (plugin should NOT be running)
ps aux | grep solid_queue
# Should show NOTHING or only your grep command

# 4. Test website
curl -I https://mrdbid.com/mushrooms
# Should show: HTTP/2 200 (not 500)
```

## 2026-03-01 Addendum (Separate Incident)

**Symptoms:** CPU pegged, Puma restart loops, slow site.
**Root cause:** legacy `puma.service` ran alongside `puma-mrdbid.service` and fought over the same socket.

**Fix:**
```bash
sudo systemctl stop puma.service
sudo systemctl disable puma.service
sudo systemctl mask --force puma.service
```

This issue is unrelated to the Solid Queue strict_loading bug above.

---

## Future Monitoring

### When Solid Queue Gem Updates

Check for fixes in future versions:
```bash
# On local development machine
bundle update solid_queue
bundle show solid_queue
# Check version number and changelog
```

**Look for:**
- Fixes to strict_loading compatibility
- Rails 8 support improvements
- Plugin stability updates

**Monitor:**
- https://github.com/rails/solid_queue/issues
- https://github.com/rails/solid_queue/blob/main/CHANGELOG.md

### Re-enabling Plugin Later

When bug is fixed (Solid Queue 1.2.2+ or Rails update):

1. **Verify fix exists** in changelog
2. **Update Gemfile** and deploy
3. **Test in development** first
4. **Re-enable on production:**
   ```bash
   # Uncomment in /etc/systemd/system/puma-mrdbid.service
   Environment="SOLID_QUEUE_IN_PUMA=1"

   sudo systemctl daemon-reload
   sudo systemctl restart puma-mrdbid.service

   # Watch logs carefully
   tail -f /opt/mrdbid/shared/log/puma_stderr.log
   ```

---

## Lessons Learned

### Why This Was Confusing

1. **Two separate issues** (queue adapter config + plugin bug)
2. **Plugin bug masked by first issue** (couldn't see plugin crash until adapter fixed)
3. **Error in plugin internals** (not in application code)
4. **Server-level config** required (not just code changes)

### How We Fixed It

1. **Fixed code issues first** (queue adapter, duplicate queries)
2. **Deployed and tested** (still broken, checked logs)
3. **Found actual error** in puma_stderr.log
4. **Identified plugin as cause** (StrictLoadingViolationError)
5. **Researched plugin configuration** (found SOLID_QUEUE_IN_PUMA)
6. **Created fix plan** (disable plugin on server)
7. **Documented everything** (this file!)

### Prevention Going Forward

1. **Always check production logs** (`puma_stderr.log`) when 500 errors occur
2. **Read full error messages** (don't assume based on symptoms)
3. **Check for upstream bugs** before extensive debugging
4. **Document server-level configs** (not just code)
5. **Test in development** with matching production config

---

## Quick Reference

### Fix Command (Copy-Paste)

```bash
# SSH to production
ssh root@85.31.233.192

# Edit service file
sudo nano /etc/systemd/system/puma-mrdbid.service

# Comment out this line:
# Environment="SOLID_QUEUE_IN_PUMA=1"

# Apply changes
sudo systemctl daemon-reload
sudo systemctl restart puma-mrdbid.service

# Verify
sudo systemctl status puma-mrdbid.service
tail -50 /opt/mrdbid/shared/log/puma_stderr.log

# Test
curl -I https://mrdbid.com/mushrooms
```

### If Still Not Working

1. Check logs: `tail -100 /opt/mrdbid/shared/log/puma_stderr.log`
2. Check process: `ps aux | grep puma`
3. Check socket: `ls -la /opt/mrdbid/shared/tmp/sockets/puma.sock`
4. Restart nginx: `sudo systemctl restart nginx`
5. Check Rails log: `tail -100 /opt/mrdbid/current/log/production.log`

---

**Documentation Author:** Claude (AI Assistant)
**Date:** October 31, 2025
**Purpose:** Document the ACTUAL root cause after multiple rounds of investigation
**Status:** Server-level fix required (not just code deployment)
