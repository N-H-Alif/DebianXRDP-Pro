#!/usr/bin/env bash

# ==============================================================================
# DebianXRDP-Pro
# Installation Script
# ==============================================================================
#
# This script prepares the container after all packages have been installed.
#
# It is executed during the Docker image build.
#
# ==============================================================================

set -Eeuo pipefail

# ------------------------------------------------------------------------------
# Load Logger
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/logger.sh"

# ------------------------------------------------------------------------------
# Start
# ------------------------------------------------------------------------------

show_banner

log_info "Running installation script..."

# ------------------------------------------------------------------------------
# Create Required Directories
# ------------------------------------------------------------------------------

log_info "Creating application directories..."

mkdir -p \
    /etc/debianxrdp \
    /var/log/debianxrdp \
    /opt/debianxrdp \
    /usr/local/debianxrdp \
    /var/run/xrdp \
    /etc/skel/Desktop

log_success "Directories created."

# ------------------------------------------------------------------------------
# Set Permissions
# ------------------------------------------------------------------------------

log_info "Setting permissions..."

chmod 755 \
    /etc/debianxrdp \
    /opt/debianxrdp \
    /usr/local/debianxrdp

chmod 1777 /tmp

log_success "Permissions configured."

# ------------------------------------------------------------------------------
# Make All Scripts Executable
# ------------------------------------------------------------------------------

log_info "Making scripts executable..."

find /usr/local/bin -type f -name "*.sh" -exec chmod +x {} \;

log_success "Scripts are executable."

# ------------------------------------------------------------------------------
# Verify Required Commands
# ------------------------------------------------------------------------------

log_info "Checking required applications..."

REQUIRED_COMMANDS=(
    bash
    sudo
    xrdp
    supervisord
)

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        log_success "$cmd found."
    else
        exit_with_error "$cmd is missing."
    fi
done

# ------------------------------------------------------------------------------
# Prepare XRDP Runtime
# ------------------------------------------------------------------------------

log_info "Preparing XRDP runtime..."

mkdir -p /var/run/xrdp

touch /var/log/xrdp.log
touch /var/log/xrdp-sesman.log

chmod 644 /var/log/xrdp.log
chmod 644 /var/log/xrdp-sesman.log

log_success "XRDP runtime ready."

# ------------------------------------------------------------------------------
# Finished
# ------------------------------------------------------------------------------

log_success "Installation completed successfully."

exit 0
