# YouTube Shorts Generator

A Node.js application to generate YouTube shorts with AI-powered content creation and video processing.

## Deployment with Docker

This project can be deployed using Docker and Docker Compose, with support for both GPU and CPU-only environments.

### Prerequisites

- Docker Engine (version 17.09.0+)
- Docker Compose (version 1.17.0+)

### Setup

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd shorts-backend
   ```

2. Create an environment file:

   ```bash
   cp .env.example .env
   ```

3. Edit the `.env` file with your API keys:
   ```
   OPENAI_API_KEY=your_openai_api_key
   TOGETHER_API_KEY=your_together_api_key
   GROQ_API_KEY=your_groq_api_key
   PORT=5123
   ```

### Deployment

#### CPU-Only Deployment (Default)

Simply run:

```bash
docker-compose up -d
```

This will start:

- The main Node.js application at port 5123 (or your configured PORT)
- The Whisper transcription service in CPU-only mode

> **Note:** If you encounter version compatibility issues with Docker Compose, you may need to use `docker compose` (with a space) instead of `docker-compose` on newer Docker installations.

#### With GPU Acceleration (Optional)

If you have NVIDIA GPU hardware and want to enable GPU acceleration:

1. Install NVIDIA Container Toolkit:

   ```bash
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
   sudo systemctl restart docker
   ```

2. Edit the `docker-compose.yml` file and:

   - Remove the `WHISPER_CPU_ONLY=1` environment variable
   - Add the GPU configuration:

   ```yaml
   whisper:
     # ... existing config ...
     deploy:
       resources:
         reservations:
           devices:
             - driver: nvidia
               count: 1
               capabilities: [gpu]
   ```

3. Start the services:
   ```bash
   docker-compose up -d
   ```

### Access

The server will be accessible at `http://localhost:5123` (or your configured PORT).

## Manual Setup

If you prefer to set up the application without Docker:

### macOS

```bash
# Install dependencies
npm install

# Set up Whisper (macOS)
npm run prepare
```

### Ubuntu

```bash
# Install dependencies
npm install

# Set up Whisper (Ubuntu)
npm run prepare:ubuntu
```

Then start the application:

```bash
npm start
```
