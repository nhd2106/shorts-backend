FROM node:18-slim

WORKDIR /app

# Install dependencies for both Node.js and Whisper (Python)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Verify Python installation
RUN python3 --version && python3 -m venv --help

# Copy package files first
COPY package.json package-lock.json ./

# Copy source code and service files
COPY src ./src
COPY tsconfig.json ./

# Create contents directory and required subdirectories
RUN mkdir -p ./contents/temp && \
    mkdir -p ./contents/video && \
    mkdir -p ./contents/audio && \
    mkdir -p ./contents/images && \
    mkdir -p ./contents/script && \
    mkdir -p ./contents/cache && \
    mkdir -p ./contents/thumbnail && \
    chmod -R 755 ./contents

# Ensure the whisper setup script is executable
RUN chmod +x ./src/services/setup_whisper_ubuntu.sh

# Set up Python venv for Whisper and install Python dependencies
RUN cd ./src/services && \
    python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install torch --index-url https://download.pytorch.org/whl/cpu && \
    pip install -r requirements.txt && \
    chmod +x whisper_transcribe.py

# Install Node.js dependencies without running prepare script (we've already set up Whisper)
RUN npm ci --ignore-scripts

# Build the Node.js application
RUN npm run build

# Set environment variables with defaults
ENV NODE_ENV=production
ENV WHISPER_CPU_ONLY=1
ENV PORT=5123

# Expose the port
EXPOSE ${PORT}

# Setup supervisor to run the Node.js app
RUN apt-get update && apt-get install -y supervisor && rm -rf /var/lib/apt/lists/*

# Create supervisor config
RUN echo "[supervisord]\nnodaemon=true\n\n[program:app]\ncommand=npm start\ndirectory=/app\nautorestart=true\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\nstderr_logfile=/dev/stderr\nstderr_logfile_maxbytes=0" > /etc/supervisor/conf.d/supervisord.conf

# Start supervisor which will start the Node.js app
CMD ["/usr/bin/supervisord"] 