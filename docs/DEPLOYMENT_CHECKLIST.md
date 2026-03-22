# Deployment Checklist

## Critical Background Services

This application has **TWO** critical services that must restart after each deploy:

1. **Puma** (web server) - Automatically restarted by Capistrano
2. **Solid Queue** (background job worker) - Automatically restarted by Capistrano (if installed)

### Why Both Must Restart

**Solid Queue runs background jobs with Ruby code.** If you don't restart it after deploy, it continues running OLD CODE even though new code is deployed. This causes:

- Jobs using old broken code
- Mysterious errors that "should be fixed"
- Hours of debugging the same issue repeatedly

## Deploy Process (Automated)

```bash
cap production deploy
```

This automatically:
1. Deploys new code
2. Restarts Puma web server
3. Restarts Solid Queue worker

## Pre-Deploy Env Check (R2 + AdSense)

Verify `/opt/mrdbid/shared/.env` includes:
- `ACTIVE_STORAGE_SERVICE=r2`
- `R2_BUCKET`, `R2_ENDPOINT`, `R2_REGION`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_PUBLIC_BASE_URL`
- `ADSENSE_ENABLED` and `ADSENSE_CLIENT_ID` (public-only ads)

## Manual Restart (If Needed)

If you need to manually restart services:

```bash
# SSH to server
ssh root@85.31.233.192

# Restart Puma
sudo systemctl restart puma-mrdbid.service

# Restart Solid Queue (CRITICAL for background jobs!)
sudo systemctl restart solid-queue-mrdbid.service
```

## Legacy Puma Units (Must Stay Masked)

These legacy units must remain masked to prevent duplicate Puma instances and socket conflicts:
1. `puma.service`
2. `puma_auto_glossary.service`

Verification:
```bash
systemctl is-enabled puma.service
systemctl is-enabled puma_auto_glossary.service
# Expect: masked or not-found
```

## Verifying Background Jobs Work

After deploy, to verify Solid Queue is running with new code:

```bash
ssh root@85.31.233.192
systemctl status solid-queue-mrdbid
# Should show recent restart timestamp
```

## Common Issues

### Issue: "Background jobs still failing after deploy"
**Solution:** Restart Solid Queue: `sudo systemctl restart solid-queue-mrdbid`

### Issue: "Permission denied during cleanup"
**Status:** Known issue, safe to ignore. Cleanup fails but deploy succeeds.

### Issue: "SSH key passphrase required"
**Solution:** Add key to agent: `ssh-add ~/.ssh/id_ed25519`

## Testing Background Jobs

To test if Solid Queue is processing jobs correctly:

1. Go to website → Click "Backup My Images"
2. If it works, Solid Queue is running new code
3. If it fails with old errors, restart Solid Queue

## Files Modified for Deployment Safeguards

- `config/deploy.rb` - Adds deploy guards against legacy Puma units
- `config/puma.service` - Adds OnFailure hook for mrdbid Puma
- `config/puma-auto-glossary.service` - Adds OnFailure hook for auto-glossary Puma
- `config/puma-mycowriter.service` - Adds OnFailure hook for MycoWriter Puma
- `config/notify-on-failure@.service` - Failure notification unit template
- `script/systemd_notify_failure.sh` - Failure notification script

## Prevention Strategy

✅ **Automated** - Deploy guards prevent legacy Puma units from starting
✅ **Automated** - Solid Queue restarts automatically on deploy
✅ **Documented** - This checklist explains the issue
✅ **Commented** - Critical code sections have warnings not to remove

**If Solid Queue errors persist after deploy, restart `solid-queue-mrdbid.service` manually.**

## Failure Notifications (Recommended)

Puma units are configured to call `notify-on-failure@%n.service` on failure.
Ensure these exist on the server:
1. `/etc/systemd/system/notify-on-failure@.service`
2. `/usr/local/bin/systemd_notify_failure.sh`
3. `/etc/systemd/system/notify-on-failure.env` with `EMAIL_TO` and `EMAIL_FROM`

## Monitoring (Recommended)

Use the lightweight health endpoint for uptime checks:
- `https://mrdbid.com/health`
