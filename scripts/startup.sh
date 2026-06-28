#!/usr/bin/env bash

# ==============================================================================
# DebianXRDP-Pro
# Startup Script
# ==============================================================================
#
# Main container entrypoint.
# Initializes the environment, creates the Linux user,
# prepares runtime directories, then starts Supervisor.
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
# Environment Variables
# ------------------------------------------------------------------------------

export USERNAME="${USERNAME:-debian}"
export PASSWORD="${PASSWORD:-ChangeMe123!}"
export USER_UID="${USER_UID:-1000}"
export USER_GID="${USER_GID:-1000}"

export TZ="${TZ:-UTC}"

export LANG="${LANG:-en_US.UTF-8}"
export LANGUAGE="${LANGUAGE:-en_US:en}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

export DISPLAY_WIDTH="${DISPLAY_WIDTH:-1920}"
export DISPLAY_HEIGHT="${DISPLAY_HEIGHT:-1080}"
export DISPLAY_DEPTH="${DISPLAY_DEPTH:-24}"

export XRDP_PORT="${XRDP_PORT:-3389}"

# ------------------------------------------------------------------------------
# Configure Timezone
# ------------------------------------------------------------------------------

log_info "Configuring timezone..."

if [[ -f "/usr/share/zoneinfo/${TZ}" ]]; then
    ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
    echo "${TZ}" > /etc/timezone
    log_success "Timezone set to ${TZ}"
else
    log_warning "Timezone '${TZ}' not found. Using UTC."
fi

# ------------------------------------------------------------------------------
# Create Runtime Directories
# ------------------------------------------------------------------------------

log_info "Preparing runtime directories..."

mkdir -p /var/run/xrdp
mkdir -p /var/run/dbus
mkdir -p /var/log/debianxrdp

touch /var/log/xrdp.log
touch /var/log/xrdp-sesman.log

# ------------------------------------------------------------------------------
# Create User
# ------------------------------------------------------------------------------

log_info "Creating Linux user..."

"${SCRIPT_DIR}/create-user.sh"

# ------------------------------------------------------------------------------
# Supervisor Startup
# ------------------------------------------------------------------------------

log_info "Supervisor will manage all services."

exec /usr/bin/supervisord \
    -c /etc/supervisor/conf.d/supervisord.conf
