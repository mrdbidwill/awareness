#!/bin/bash
# Setup script for creating a dedicated deploy user on production server
# Run this script as root on your production server: sudo bash setup_deploy_user.sh

set -e  # Exit on any error

echo "=========================================="
echo "Creating Deploy User for mrdbid"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
   echo "ERROR: Please run as root (sudo bash setup_deploy_user.sh)"
   exit 1
fi

DEPLOY_USER="deploy"
APP_PATH="/opt/mrdbid"
RUBY_VERSION="3.4.3"

echo "Step 1: Creating user '$DEPLOY_USER'..."
if id "$DEPLOY_USER" &>/dev/null; then
    echo "  User '$DEPLOY_USER' already exists, skipping creation"
else
    adduser --disabled-password --gecos "" $DEPLOY_USER
    echo "  ✓ User created"
fi

echo ""
echo "Step 2: Adding '$DEPLOY_USER' to sudo group..."
usermod -aG sudo $DEPLOY_USER
echo "  ✓ Added to sudo group"

echo ""
echo "Step 3: Setting up SSH directory..."
mkdir -p /home/$DEPLOY_USER/.ssh
chmod 700 /home/$DEPLOY_USER/.ssh

# Copy authorized_keys from root if it exists
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys /home/$DEPLOY_USER/.ssh/authorized_keys
    chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys
    chown -R $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh
    echo "  ✓ Copied SSH keys from root"
else
    echo "  ! Warning: /root/.ssh/authorized_keys not found"
    echo "    You'll need to manually add SSH keys to /home/$DEPLOY_USER/.ssh/authorized_keys"
fi

echo ""
echo "Step 4: Installing rbenv for '$DEPLOY_USER'..."
sudo -u $DEPLOY_USER bash << 'EOF_RBENV'
set -e

# Install rbenv if not already installed
if [ ! -d "$HOME/.rbenv" ]; then
    echo "  Installing rbenv..."
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    cd ~/.rbenv && src/configure && make -C src || true

    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc

    # Install ruby-build
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo "  ✓ rbenv installed"
else
    echo "  rbenv already installed"
fi

# Source rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Install Ruby if not already installed
if ! rbenv versions | grep -q "3.4.3"; then
    echo "  Installing Ruby 3.4.3 (this may take 5-10 minutes)..."
    rbenv install 3.4.3
    echo "  ✓ Ruby 3.4.3 installed"
else
    echo "  Ruby 3.4.3 already installed"
fi

rbenv global 3.4.3
rbenv rehash

# Install bundler
gem install bundler
rbenv rehash

echo "  ✓ Ruby environment ready"
EOF_RBENV

echo ""
echo "Step 5: Transferring ownership of application directory..."
if [ -d "$APP_PATH" ]; then
    chown -R $DEPLOY_USER:$DEPLOY_USER $APP_PATH
    echo "  ✓ Ownership transferred: $APP_PATH"
else
    echo "  ! Warning: $APP_PATH doesn't exist yet (will be created on first deploy)"
fi

echo ""
echo "Step 6: Configuring sudo access (passwordless for systemctl)..."
cat > /etc/sudoers.d/$DEPLOY_USER << 'EOF_SUDO'
# Allow deploy user to manage systemd services without password
deploy ALL=(ALL) NOPASSWD: /bin/systemctl start puma-mrdbid.service
deploy ALL=(ALL) NOPASSWD: /bin/systemctl stop puma-mrdbid.service
deploy ALL=(ALL) NOPASSWD: /bin/systemctl restart puma-mrdbid.service
deploy ALL=(ALL) NOPASSWD: /bin/systemctl reload puma-mrdbid.service
deploy ALL=(ALL) NOPASSWD: /bin/systemctl status puma-mrdbid.service
deploy ALL=(ALL) NOPASSWD: /bin/systemctl enable puma-mrdbid.service
deploy ALL=(ALL) NOPASSWD: /bin/systemctl disable puma-mrdbid.service
deploy ALL=(ALL) NOPASSWD: /bin/systemctl daemon-reload
deploy ALL=(ALL) NOPASSWD: /bin/journalctl -xeu puma-mrdbid.service*
deploy ALL=(ALL) NOPASSWD: /bin/cp * /etc/systemd/system/puma-mrdbid.service
EOF_SUDO

chmod 440 /etc/sudoers.d/$DEPLOY_USER
echo "  ✓ Sudo configuration created"

echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Test SSH login: ssh deploy@85.31.233.192"
echo "2. Update config/deploy/production.rb on your local machine"
echo "3. Run: cap production deploy"
echo ""
echo "Verification:"
echo "  sudo -u deploy -i rbenv versions  # Should show Ruby 3.4.3"
echo "  ls -la $APP_PATH                  # Should be owned by deploy:deploy"
echo ""
