#!/usr/bin/env bash

# ==============================================================================
# DebianXRDP-Pro
# Startup Script
# ==============================================================================
#
# This script is the main entrypoint of the container.
# It performs initialization, creates the user, starts required
# services, and finally launches Supervisor.
#
# ==============================================================================

set -Eeuo pipefail

# ------------------------------------------------------------------------------
# Script Directory
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------------------------
# Load Logger
# ------------------------------------------------------------------------------

source "${SCRIPT_DIR}/logger.sh"

show_banner

log_info "Starting DebianXRDP-Pro..."

# ------------------------------------------------------------------------------
# Environment Defaults
# ------------------------------------------------------------------------------

export USERNAME="${USERNAME:-debian}"
export PASSWORD="${PASSWORD:-ChangeMe123!}"
export TZ="${TZ:-UTC}"
export LANG="${LANG:-en_US.UTF-8}"
export DISPLAY_WIDTH="${DISPLAY_WIDTH:-1920}"
export DISPLAY_HEIGHT="${DISPLAY_HEIGHT:-1080}"
export DISPLAY_DEPTH="${DISPLAY_DEPTH:-24}"

# ------------------------------------------------------------------------------
# Configure Timezone
# ------------------------------------------------------------------------------

log_info "Configuring timezone..."

if [ -f "/usr/share/zoneinfo/${TZ}" ]; then
    ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
    echo "${TZ}" >/etc/timezone
    log_success "Timezone set to ${TZ}"
else
    log_warning "Timezone '${TZ}' not found. Using UTC."
fi

# ------------------------------------------------------------------------------
# Create User
# ------------------------------------------------------------------------------

log_info "Initializing user..."

"${SCRIPT_DIR}/create-user.sh"

# ------------------------------------------------------------------------------
# Prepare Runtime Directories
# ------------------------------------------------------------------------------

log_info "Preparing runtime directories..."

mkdir -p /var/run/dbus
mkdir -p /var/run/xrdp

touch /var/log/xrdp.log
touch /var/log/xrdp-sesman.log

# ------------------------------------------------------------------------------
# Start DBus
# ------------------------------------------------------------------------------

log_info "Starting DBus..."

dbus-daemon --system

log_success "DBus started."

# ------------------------------------------------------------------------------
# Start XRDP Services
# ------------------------------------------------------------------------------

log_info "Starting XRDP services..."

if ! pgrep -x xrdp-sesman >/dev/null; then
    xrdp-sesman
fi

if ! pgrep -x xrdp >/dev/null; then
    xrdp
fi

log_success "XRDP services started."

# ------------------------------------------------------------------------------
# Start Supervisor
# ------------------------------------------------------------------------------

log_info "Starting Supervisor..."

exec /usr/bin/supervisord \
    -c /etc/supervisor/conf.d/supervisord.conf
