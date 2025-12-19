FROM mcr.microsoft.com/devcontainers/javascript-node:1-18-bullseye

# 2. Install GitHub CLI (gh) and other utilities
RUN type -p curl >/dev/null || (apt-get update && apt-get install -y curl)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh

# 3. Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# 4. Configure Zsh to use Starship
# We append the init command to the .zshrc file
RUN echo 'eval "$(starship init zsh)"' >> /home/node/.zshrc

# 5. Set Zsh as the default shell for the 'node' user
USER node
SHELL ["/bin/zsh", "-c"]