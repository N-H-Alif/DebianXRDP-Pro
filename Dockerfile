# ==============================================================================
# DebianXRDP-Pro
# Production-ready Debian 12 + XFCE4 + XRDP Docker Image
# ==============================================================================

FROM debian:12-slim

# ------------------------------------------------------------------------------
# Image Metadata
# ------------------------------------------------------------------------------

LABEL maintainer="MD Naim Hasan Alif"
LABEL org.opencontainers.image.title="DebianXRDP-Pro"
LABEL org.opencontainers.image.description="Production-ready Debian 12 XRDP Desktop optimized for Railway and Docker."
LABEL org.opencontainers.image.version="0.1.0"
LABEL org.opencontainers.image.licenses="MIT"

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=UTC \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# ------------------------------------------------------------------------------
# Install Packages
# ------------------------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \

    # Core
    apt-utils \
    bash \
    sudo \
    tini \
    supervisor \

    # Desktop
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    xrdp \
    xorgxrdp \

    # Browsers
    firefox-esr \

    # Development
    git \
    curl \
    wget \
    nano \
    vim \
    python3 \
    python3-pip \
    python3-venv \

    # Network
    iproute2 \
    iputils-ping \
    net-tools \
    procps \

    # Archive
    zip \
    unzip \
    p7zip-full \

    # Fonts
    fonts-dejavu \
    fonts-liberation \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-color-emoji \

    # Locale
    locales \
    locales-all \

    # SSL
    ca-certificates \

    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# Configure Locale
# ------------------------------------------------------------------------------

RUN locale-gen en_US.UTF-8

# ------------------------------------------------------------------------------
# Create Directories
# ------------------------------------------------------------------------------

RUN mkdir -p \
    /etc/debianxrdp \
    /var/log/debianxrdp \
    /opt/debianxrdp \
    /usr/local/debianxrdp

# ------------------------------------------------------------------------------
# Copy Configuration
# ------------------------------------------------------------------------------

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY config/xrdp.ini /etc/xrdp/xrdp.ini

COPY config/sesman.ini /etc/xrdp/sesman.ini

COPY config/startwm.sh /etc/xrdp/startwm.sh

# ------------------------------------------------------------------------------
# Copy Scripts
# ------------------------------------------------------------------------------

COPY scripts/ /usr/local/bin/

RUN chmod +x /usr/local/bin/*.sh

# ------------------------------------------------------------------------------
# Ports
# ------------------------------------------------------------------------------

EXPOSE 3389

# ------------------------------------------------------------------------------
# Health Check
# ------------------------------------------------------------------------------

HEALTHCHECK \
--interval=30s \
--timeout=10s \
--start-period=60s \
--retries=5 \
CMD /usr/local/bin/healthcheck.sh

# ------------------------------------------------------------------------------
# Entry Point
# ------------------------------------------------------------------------------

ENTRYPOINT ["/usr/bin/tini","--"]

CMD ["/usr/local/bin/startup.sh"]
