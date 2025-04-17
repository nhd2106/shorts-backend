# YouTube Shorts Generator

A Node.js application to generate YouTube shorts with AI-powered content creation and video processing.

## Deployment with Docker (Combined Container)

This project can be deployed using Docker and Docker Compose in a single combined container that includes both the Node.js application and the Whisper transcription service.

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

#### Build and Run the Container

Simply run:

```bash
docker-compose up -d
```

This will:

- Build a single container with both Node.js and Python/Whisper
- Run the container and expose port 5123 (or your configured PORT)
- Create a volume for the contents directory for data persistence

> **Note:** If you encounter version compatibility issues with Docker Compose, you may need to use `docker compose` (with a space) instead of `docker-compose` on newer Docker installations.

#### Testing Whisper Transcription

To verify that the Whisper transcription functionality is working:

1. Make sure you have an audio file for testing (e.g., test.mp3, sample.wav)
2. Run the test script:
   ```bash
   ./test-whisper.sh your-audio-file.mp3
   ```

This script will copy your audio file to the correct location and run the transcription within the container.

### Accessing Your Application

The server will be accessible at `http://localhost:5123` (or your configured PORT).

### Troubleshooting

If you have any issues with the container:

1. Check the logs:

   ```bash
   docker-compose logs
   ```

2. For more detailed logs with continuous monitoring:

   ```bash
   docker-compose logs -f
   ```

3. To access the container's shell for debugging:
   ```bash
   docker-compose exec app bash
   ```

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
