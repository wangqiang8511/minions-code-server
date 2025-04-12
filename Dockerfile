FROM lscr.io/linuxserver/code-server:latest

RUN sudo /app/code-server/bin/code-server --install-extension saoudrizwan.claude-dev --force