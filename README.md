# PickleStoreApp Docker Development Environment

This repository includes a Dockerfile for building a Swift-based development environment for the PickleStoreApp iOS project.

## Usage Instructions

### 1. Build the Docker Image

```bash
cd docker
docker build -t picklestoreapp-dev .
```

### 2. Run the Docker Container

```bash
docker run -it --rm -v $(pwd)/../:/workspace picklestoreapp-dev
```

- The `/workspace` directory inside the container will map to your project root.
- All required tools (Swift, git, curl, Homebrew, swiftformat) are pre-installed.

### 3. Notes
- This container is suitable for Swift-based development and CI builds.
- App Store submission must be performed on macOS.
- For iOS simulator and device builds, use a macOS machine.

Refer to `/plan/infrastructure-docker-iosapp-1.md` for the full implementation plan.
# PickleStoreApp
