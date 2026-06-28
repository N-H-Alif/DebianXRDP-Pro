#!/usr/bin/env bash

# ==============================================================================
# DebianXRDP-Pro
# Create Linux User
# ==============================================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/logger.sh"

# ------------------------------------------------------------------------------
# Load Environment Variables
# ------------------------------------------------------------------------------

USERNAME="${USERNAME:-debian}"
PASSWORD="${PASSWORD:-ChangeMe123!}"
USER_UID="${USER_UID:-1000}"
USER_GID="${USER_GID:-1000}"

# ------------------------------------------------------------------------------
# Validate Username
# ------------------------------------------------------------------------------

if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    exit_with_error "Invalid username: ${USERNAME}"
fi

# ------------------------------------------------------------------------------
# Create Group
# ------------------------------------------------------------------------------

if getent group "${USERNAME}" >/dev/null 2>&1; then
    log_info "Group already exists."
else
    log_info "Creating group..."
    groupadd -g "${USER_GID}" "${USERNAME}"
    log_success "Group created."
fi

# ------------------------------------------------------------------------------
# Create User
# ------------------------------------------------------------------------------

if id "${USERNAME}" >/dev/null 2>&1; then
    log_info "User already exists."
else

    log_info "Creating user..."

    useradd \
        --uid "${USER_UID}" \
        --gid "${USER_GID}" \
        --create-home \
        --shell /bin/bash \
        "${USERNAME}"

    log_success "User created."

fi

# ------------------------------------------------------------------------------
# Set Password
# ------------------------------------------------------------------------------

echo "${USERNAME}:${PASSWORD}" | chpasswd

log_success "Password updated."

# ------------------------------------------------------------------------------
# Add To Sudo Group
# ------------------------------------------------------------------------------

usermod -aG sudo "${USERNAME}"

log_success "Added to sudo group."

# ------------------------------------------------------------------------------
# Prepare Home Directory
# ------------------------------------------------------------------------------

mkdir -p "/home/${USERNAME}/Desktop"
mkdir -p "/home/${USERNAME}/Downloads"
mkdir -p "/home/${USERNAME}/Documents"
mkdir -p "/home/${USERNAME}/Pictures"

chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}"

log_success "Home directory prepared."

# ------------------------------------------------------------------------------
# Configure XRDP Session
# ------------------------------------------------------------------------------

cat > "/home/${USERNAME}/.xsession" <<EOF
startxfce4
EOF

chown "${USERNAME}:${USERNAME}" "/home/${USERNAME}/.xsession"

chmod 644 "/home/${USERNAME}/.xsession"

log_success "XRDP session configured."

# ------------------------------------------------------------------------------
# Finished
# ------------------------------------------------------------------------------

log_success "User initialization completed."
