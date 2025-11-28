# infrastructure-docker-iosapp-1
# Dockerfile for Swift-based iOS app development environment
# See /plan/infrastructure-docker-iosapp-1.md for implementation plan

FROM swift:5.9 as builder

LABEL maintainer="iOS DevOps Team"
LABEL purpose="iOS app development environment for PickleStoreApp"

# Install basic CLI tools
RUN apt-get update && \
    apt-get install -y git curl wget libssl-dev libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*


## Homebrew and swiftformat installation removed due to SSL/cert issues

# Set working directory
WORKDIR /workspace

# Default command
CMD ["bash"]
