FROM lscr.io/linuxserver/code-server:latest

# Install Cline extension into the directory expected at runtime when /config is mounted
RUN sudo /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension saoudrizwan.claude-dev --force
