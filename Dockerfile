# Multi-stage build for Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory
WORKDIR /app

# Proxy configuration for build stage
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG ALL_PROXY
ARG NO_PROXY
ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY
ENV ALL_PROXY=$ALL_PROXY
ENV NO_PROXY=$NO_PROXY

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Generate code (injectable, json_serializable, etc.)
RUN flutter packages pub run build_runner build --delete-conflicting-outputs

# Build web application
RUN flutter build web --release

# Production stage with Nginx
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built web application
COPY --from=build /app/build/web /usr/share/nginx/html

# Create directory for logs
RUN mkdir -p /var/log/nginx

# Create startup script to generate env.js file (FIXED for Flutter Web)
RUN echo '#!/bin/sh' > /usr/local/bin/generate-env.sh && \
    echo 'cat > /usr/share/nginx/html/env.js <<EOF' >> /usr/local/bin/generate-env.sh && \
    echo '// Environment configuration generated at runtime' >> /usr/local/bin/generate-env.sh && \
    echo 'window.ENV = {' >> /usr/local/bin/generate-env.sh && \
    echo '  OPENAI_API_KEY: "${OPENAI_API_KEY:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  GOOGLE_API_KEY: "${GOOGLE_API_KEY:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  GOOGLE_API_KEYS_FALLBACK: "${GOOGLE_API_KEYS_FALLBACK:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  ALL_PROXY: "${ALL_PROXY:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  BACKUP_PROXIES: "${BACKUP_PROXIES:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  HTTP_PROXY: "${HTTP_PROXY:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  HTTPS_PROXY: "${HTTPS_PROXY:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  NO_PROXY: "${NO_PROXY:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  SERVER_HOST: "${SERVER_HOST:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  STABILITY_API_KEY: "${STABILITY_API_KEY:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  HUGGINGFACE_API_KEY: "${HUGGINGFACE_API_KEY:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  YC_API_KEY_ID: "${YC_API_KEY_ID:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  YC_API_KEY: "${YC_API_KEY:-}",' >> /usr/local/bin/generate-env.sh && \
    echo '  YC_FOLDER_ID: "${YC_FOLDER_ID:-}"' >> /usr/local/bin/generate-env.sh && \
    echo '};' >> /usr/local/bin/generate-env.sh && \
    echo 'EOF' >> /usr/local/bin/generate-env.sh && \
    chmod +x /usr/local/bin/generate-env.sh

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["sh", "-c", "/usr/local/bin/generate-env.sh && nginx -g 'daemon off;'"]
