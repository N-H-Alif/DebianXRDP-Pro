#!/usr/bin/env bash

# ==============================================================================
# DebianXRDP-Pro
# XRDP Window Manager Startup Script
# ==============================================================================

set -Eeuo pipefail

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

export LANG="${LANG:-en_US.UTF-8}"
export LANGUAGE="${LANGUAGE:-en_US:en}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE
export DESKTOP_SESSION=xfce
export XDG_CONFIG_DIRS=/etc/xdg

# ------------------------------------------------------------------------------
# Source System Profile
# ------------------------------------------------------------------------------

if [ -f /etc/profile ]; then
    source /etc/profile
fi

if [ -f "${HOME}/.profile" ]; then
    source "${HOME}/.profile"
fi

# ------------------------------------------------------------------------------
# Start DBus User Session
# ------------------------------------------------------------------------------

if command -v dbus-launch >/dev/null 2>&1; then
    eval "$(dbus-launch --sh-syntax)"
fi

# ------------------------------------------------------------------------------
# Create User Runtime Directory
# ------------------------------------------------------------------------------

export XDG_RUNTIME_DIR="/tmp/runtime-${USER}"

mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

# ------------------------------------------------------------------------------
# Disable Screen Saver
# ------------------------------------------------------------------------------

xsetroot -solid "#202020" >/dev/null 2>&1 || true

# ------------------------------------------------------------------------------
# Start XFCE
# ------------------------------------------------------------------------------

exec startxfce4
