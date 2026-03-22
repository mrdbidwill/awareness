#!/bin/bash
# Setup script for nginx configuration on production server
# Run this on the production server as root

set -e

echo "==== Nginx Configuration Setup for Database Exports ===="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

# Check if nginx config exists
if [ ! -f "/etc/nginx/sites-available/awareness" ]; then
  echo "ERROR: /etc/nginx/sites-available/awareness not found"
  echo "Please copy config/nginx_site.conf to /etc/nginx/sites-available/awareness first"
  exit 1
fi

# Backup existing config
echo "1. Backing up existing nginx config..."
cp /etc/nginx/sites-available/awareness /etc/nginx/sites-available/awareness.backup.$(date +%Y%m%d_%H%M%S)

# Test nginx configuration
echo "2. Testing nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
  echo "✓ Nginx configuration is valid"

  # Create exports directory
  echo "3. Creating exports directory..."
  mkdir -p /opt/awareness/current/public/tmp/exports
  chown root:root /opt/awareness/current/public/tmp/exports
  chmod 755 /opt/awareness/current/public/tmp/exports
  echo "✓ Created /opt/awareness/current/public/tmp/exports"

  # Reload nginx
  echo "4. Reloading nginx..."
  systemctl reload nginx
  echo "✓ Nginx reloaded successfully"

  echo ""
  echo "==== Setup Complete ===="
  echo "Database exports will now work via web download."
  echo "Large files (420MB+) will be served efficiently by nginx."
else
  echo "✗ Nginx configuration test failed"
  echo "Please fix the configuration errors above"
  exit 1
fi
