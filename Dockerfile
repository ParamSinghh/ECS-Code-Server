FROM codercom/code-server:latest

# Switch to root to do setup
USER root

# Create a directory for the workspace
RUN mkdir -p /home/coder/project

# Set correct permissions
RUN chown -R coder:coder /home/coder/project

# Switch back to non-root user (best practice)
USER coder

# Expose the port code-server runs on
EXPOSE 8080

# Start code-server
ENTRYPOINT ["dumb-init", "code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none"]
