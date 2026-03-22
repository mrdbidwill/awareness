# frozen_string_literal: true
# ============================================================================
# PUMA WEB SERVER CONFIGURATION
# ============================================================================
# This file configures Puma, the Rails application server.
# Documentation: https://puma.io/puma/Puma/DSL.html
#
# PRODUCTION DEPLOYMENT:
# - Managed by systemd service: /etc/systemd/system/puma-awareness.service
# - Socket: /opt/awareness/shared/tmp/sockets/puma.sock
# - PID file: /opt/awareness/shared/tmp/pids/puma.pid
# - Logs: /opt/awareness/shared/log/puma_stdout.log and puma_stderr.log
#
# TROUBLESHOOTING PRODUCTION ISSUES:
# - Check service status: sudo systemctl status puma-awareness.service
# - View logs: sudo journalctl -xeu puma-awareness.service
# - Restart: sudo systemctl restart puma-awareness.service
# - Check stderr: tail -f /opt/awareness/shared/log/puma_stderr.log
#
# ⚠️  CRITICAL: Puma is controlled by systemd in production (not Capistrano)
# See config/deploy.rb lines 56-117 for systemd management tasks
# ============================================================================

# ============================================================================
# THREADING CONFIGURATION
# ============================================================================
# Puma uses threads to handle concurrent requests within each process.
#
# IMPORTANT: Database connection pool MUST be >= thread count
# See config/database.yml line 15: pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
#
# Production uses 3 threads per worker as a balance between:
# - Throughput (more threads = more concurrent requests)
# - Latency (too many threads = GVL contention in CRuby)
#
# ⚠️  WARNING: If you increase threads, also increase database pool size
# ============================================================================
threads_count = ENV.fetch('RAILS_MAX_THREADS', 3)
threads threads_count, threads_count

# ============================================================================
# PRODUCTION vs DEVELOPMENT CONFIGURATION
# ============================================================================
# Production: Uses Unix socket (faster, more secure)
# Development: Uses TCP port 3000 (easier debugging)
# ============================================================================
if ENV['RAILS_ENV'] == 'production'
  # Use absolute paths in production - required by systemd service
  bind "unix://#{ENV['PUMA_SOCKET'] || '/opt/awareness/shared/tmp/sockets/puma.sock'}"

  # Set up pid and state files for process management
  pidfile ENV['PUMA_PID'] || '/opt/awareness/shared/tmp/pids/puma.pid'
  state_path ENV['PUMA_STATE'] || '/opt/awareness/shared/tmp/pids/puma.state'

  # Logging - redirects stdout/stderr to log files
  stdout_redirect ENV['PUMA_STDOUT'] || '/opt/awareness/shared/log/puma_stdout.log',
                  ENV['PUMA_STDERR'] || '/opt/awareness/shared/log/puma_stderr.log', true
else
  port ENV.fetch('PORT', 3000)
end

# ============================================================================
# RESTART PLUGIN
# ============================================================================
# Allows `bin/rails restart` command to work by touching tmp/restart.txt
# Puma monitors this file and gracefully restarts when it changes
# ============================================================================
plugin :tmp_restart

# ============================================================================
# SOLID QUEUE PLUGIN - OPTIONAL (CURRENTLY DISABLED DUE TO BUG)
# ============================================================================
# Runs the Solid Queue background job supervisor inside Puma process.
# This is for single-server deployments where you don't want a separate process.
#
# ⚠️  CRITICAL BUG: Solid Queue 1.2.1 + Rails 8 Strict Loading Incompatibility
#
# SYMPTOMS WHEN ENABLED:
# - 500 errors on ALL pages
# - Puma crashes during boot with: ActiveRecord::StrictLoadingViolationError
# - Error: `SolidQueue::Process` is marked for strict_loading
# - Cannot lazy load `:supervisees` association
#
# ROOT CAUSE:
# Solid Queue's internal models have strict_loading enabled (Rails 8 feature)
# but the plugin code tries to lazy load associations during initialization.
# This causes a crash before Puma can accept web requests.
#
# CURRENT STATUS: DISABLED
# The plugin is NOT loaded because ENV['SOLID_QUEUE_IN_PUMA'] is not set.
#
# ⚠️  DO NOT ENABLE until Solid Queue bug is fixed (check gem version 1.2.2+)
#
# TO ENABLE LATER (when bug is fixed):
# 1. Check Solid Queue changelog for Rails 8 strict_loading fix
# 2. Update gem: bundle update solid_queue
# 3. Test in development first!
# 4. On production, edit: /etc/systemd/system/puma-awareness.service
# 5. Add line: Environment="SOLID_QUEUE_IN_PUMA=1"
# 6. Reload: sudo systemctl daemon-reload
# 7. Restart: sudo systemctl restart puma-awareness.service
# 8. Monitor logs: tail -f /opt/awareness/shared/log/puma_stderr.log
#
# ALTERNATIVE (no bug):
# Use separate Solid Queue service instead of plugin (see SOLID_QUEUE_SETUP.md Option B)
#
# NOTE: This requires Solid Queue database to be set up (see production.rb)
# The queue database exists, queue adapter is configured, but plugin is disabled.
#
# MORE INFO: See PRODUCTION_500_ERROR_FIX_ACTUAL.md
# ============================================================================
plugin :solid_queue if ENV['SOLID_QUEUE_IN_PUMA']

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV['PIDFILE'] if ENV['PIDFILE']
