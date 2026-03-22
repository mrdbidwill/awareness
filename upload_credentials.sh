#!/bin/bash
# Upload production credentials to VPS

echo "Uploading production credentials to VPS..."

# Create credentials directory on VPS if it doesn't exist
ssh root@85.31.233.192 "mkdir -p /opt/mrdbid/shared/config/credentials"
if [ $? -eq 0 ]; then
    echo "✓ Credentials directory ready"
else
    echo "✗ Failed to create credentials directory"
    exit 1
fi

# Upload the encryption key
scp config/credentials/production.key root@85.31.233.192:/opt/mrdbid/shared/config/credentials/
if [ $? -eq 0 ]; then
    echo "✓ Production key uploaded"
else
    echo "✗ Failed to upload production key"
    exit 1
fi

# Upload the encrypted credentials
scp config/credentials/production.yml.enc root@85.31.233.192:/opt/mrdbid/shared/config/credentials/
if [ $? -eq 0 ]; then
    echo "✓ Production credentials uploaded"
else
    echo "✗ Failed to upload production credentials"
    exit 1
fi

# Set correct permissions on VPS
ssh root@85.31.233.192 "chmod 600 /opt/mrdbid/shared/config/credentials/production.key && chmod 644 /opt/mrdbid/shared/config/credentials/production.yml.enc"
if [ $? -eq 0 ]; then
    echo "✓ Permissions set correctly"
else
    echo "✗ Failed to set permissions"
    exit 1
fi

# Restart Puma
echo "Restarting Puma..."
ssh root@85.31.233.192 "cd /opt/mrdbid/current && kill -SIGUSR2 \$(cat /opt/mrdbid/shared/tmp/pids/puma.pid)"
if [ $? -eq 0 ]; then
    echo "✓ Puma restarted"
else
    echo "✗ Failed to restart Puma"
    exit 1
fi

echo ""
echo "Production credentials configured successfully!"
echo "SMTP settings:"
echo "  Server: smtp.hostinger.com:587"
echo "  From: contact@mrdbid.com"
