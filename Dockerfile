# ---- Stage 1: Node.js Build Stage ----
FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --only=production && npm cache clean --force

COPY . .
RUN npm run build

# ---- Stage 2: Final Stage with Python + Node.js + OpenCV + MediaPipe ----
FROM python:3.10-slim AS production

WORKDIR /app

# Install Python dependencies
COPY requirements.txt ./
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install --timeout=1000 --no-cache-dir -r requirements.txt

# System dependencies for opencv-python-headless and mediapipe
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        git \
        curl \
        libgl1 \
        libglib2.0-0 \
        libglib2.0-bin \
        libgstreamer1.0-0 \
        supervisor \
        build-essential \
        cmake \
        libopencv-dev \
        nodejs \
        npm && \
    rm -rf /var/lib/apt/lists/*

# Copy Node.js build artifacts
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/client ./client
COPY --from=builder /app/server ./server
COPY --from=builder /app/shared ./shared
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json* ./package-lock.json
COPY --from=builder /app/vite.config.ts ./vite.config.ts
COPY --from=builder /app/vite.config.server.ts ./vite.config.server.ts
COPY --from=builder /app/tsconfig.json ./tsconfig.json

# Install Node.js production deps
RUN npm ci --only=production && npm cache clean --force

# Add non-root user
RUN addgroup --gid 1001 nodejs && \
    adduser --uid 1001 --disabled-password --gecos "" --ingroup nodejs appuser && \
    chown -R appuser:nodejs /app

USER appuser

# Environment variables
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    IN_DOCKER=true \
    PYTHONPATH=/app

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/api/ping || exit 1

CMD ["npm", "start"]
