# -----------------------------------------------------------------------------
# DebianXRDP-Pro
# Production-ready Debian 12 + XFCE4 + XRDP Container
# -----------------------------------------------------------------------------

FROM debian:12-slim

LABEL maintainer="N-H-Alif"
LABEL org.opencontainers.image.title="DebianXRDP-Pro"
LABEL org.opencontainers.image.description="Production-ready Debian 12 XRDP Desktop for Railway and Docker."
LABEL org.opencontainers.image.version="0.1.0"

ENV DEBIAN_FRONTEND=noninteractive

# Update system and install base packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    supervisor \
    dbus-x11 \
    xrdp \
    xfce4 \
    xfce4-terminal \
    firefox-esr \
    xorgxrdp \
    sudo \
    bash \
    curl \
    wget \
    nano \
    vim \
    git \
    unzip \
    zip \
    ca-certificates \
    locales \
    procps \
    net-tools \
    iproute2 \
    htop \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini","--"]

CMD ["/bin/bash"]
