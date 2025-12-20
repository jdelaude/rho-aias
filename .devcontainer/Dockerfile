FROM mcr.microsoft.com/devcontainers/javascript-node:1-18-bullseye

# 1. Install Basic Tools + Playwright/Cypress Dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    # Productivity Tools
    fzf \
    ripgrep \
    bat \
    unzip \
    zip \
    iputils-ping \
    dnsutils \
    tmux \
    # Headless Browser Dependencies (Testing.md)
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# 2. Install Zoxide (Smart Directory Navigation)
RUN curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash \
    && mv /root/.local/bin/zoxide /usr/local/bin/zoxide \
    && chmod 755 /usr/local/bin/zoxide

# 3. Set the default user to 'node' for any subsequent Docker commands
USER node

# 4. Explicitly set Zsh as the shell. 
# Note: Zsh itself is installed via the 'common-utils' feature in devcontainer.json,
# but this ensures the image knows to use it if invoked manually.
SHELL ["/bin/zsh", "-c"]