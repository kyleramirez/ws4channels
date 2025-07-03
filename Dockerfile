# Use multi-stage build for better ARM64 compatibility
FROM node:18-slim AS base

# Install system dependencies including Chromium and pnpm
RUN apt-get update && apt-get install -y \
    ffmpeg \
    chromium \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

# Set environment variables for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

WORKDIR /app

# Copy package files
COPY package*.json pnpm-lock.yaml* ./

# Install dependencies with pnpm for better ARM64 compatibility
RUN pnpm install --frozen-lockfile --prod

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p /app/music /app/logo /app/output

# Copy music and logo files (will fail if directories don't exist, but that's OK)
COPY music/ /app/music/
COPY logo/ /app/logo/

# Expose the stream port
EXPOSE 9798

# Set the default command
CMD ["node", "index.js"]

