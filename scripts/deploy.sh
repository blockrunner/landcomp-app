#!/bin/bash

# LandComp App Deployment Script
# This script sets up the application on a production server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="landcomp-app"
APP_DIR="/opt/$APP_NAME"
DOCKER_COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"
ENV_FILE="$APP_DIR/.env"
BACKUP_DIR="/opt/backups/$APP_NAME"

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root for security reasons"
        exit 1
    fi
}

# Install Docker if not present
install_docker() {
    log "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        log "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        success "Docker installed successfully"
    else
        success "Docker is already installed"
    fi

    if ! command -v docker-compose &> /dev/null; then
        log "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        success "Docker Compose installed successfully"
    else
        success "Docker Compose is already installed"
    fi
}

# Install Git if not present
install_git() {
    log "Checking Git installation..."
    
    if ! command -v git &> /dev/null; then
        log "Installing Git..."
        sudo apt-get update
        sudo apt-get install -y git
        success "Git installed successfully"
    else
        success "Git is already installed"
    fi
}

# Create application directory
setup_app_directory() {
    log "Setting up application directory..."
    
    if [ ! -d "$APP_DIR" ]; then
        sudo mkdir -p "$APP_DIR"
        sudo chown $USER:$USER "$APP_DIR"
        success "Application directory created: $APP_DIR"
    else
        success "Application directory already exists: $APP_DIR"
    fi
}

# Clone or update repository
setup_repository() {
    log "Setting up repository..."
    
    if [ ! -d "$APP_DIR/.git" ]; then
        log "Cloning repository..."
        git clone https://github.com/blockrunner/landcomp-app.git "$APP_DIR"
        success "Repository cloned successfully"
    else
        log "Updating repository..."
        cd "$APP_DIR"
        git pull origin main
        success "Repository updated successfully"
    fi
}

# Setup environment file
setup_environment() {
    log "Setting up environment configuration..."
    
    if [ ! -f "$ENV_FILE" ]; then
        if [ -f "$APP_DIR/env.example" ]; then
            cp "$APP_DIR/env.example" "$ENV_FILE"
            warning "Environment file created from template. Please edit $ENV_FILE with your actual values."
        else
            error "Environment template not found. Please create $ENV_FILE manually."
            exit 1
        fi
    else
        success "Environment file already exists"
    fi
}

# Create production docker-compose file
create_production_compose() {
    log "Creating production Docker Compose configuration..."
    
    cat > "$DOCKER_COMPOSE_FILE" << EOF
version: '3.8'

services:
  landcomp-app:
    image: ghcr.io/blockrunner/landcomp-app:latest
    container_name: landcomp-app
    ports:
      - "80:80"
      - "443:443"
    environment:
      - NODE_ENV=production
    env_file:
      - .env
    volumes:
      - ./logs:/var/log/nginx
      - ./ssl:/etc/nginx/ssl:ro
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - landcomp-network

networks:
  landcomp-network:
    driver: bridge

volumes:
  logs:
EOF

    success "Production Docker Compose file created"
}

# Setup SSL certificates (Let's Encrypt)
setup_ssl() {
    log "Setting up SSL certificates..."
    
    # Install certbot if not present
    if ! command -v certbot &> /dev/null; then
        log "Installing Certbot..."
        sudo apt-get update
        sudo apt-get install -y certbot python3-certbot-nginx
        success "Certbot installed successfully"
    fi
    
    # Create SSL directory
    sudo mkdir -p "$APP_DIR/ssl"
    sudo chown $USER:$USER "$APP_DIR/ssl"
    
    warning "SSL certificates setup requires domain configuration. Please run:"
    warning "sudo certbot certonly --standalone -d your-domain.com"
    warning "Then copy certificates to $APP_DIR/ssl/"
}

# Setup systemd service
setup_systemd_service() {
    log "Setting up systemd service..."
    
    sudo tee /etc/systemd/system/landcomp-app.service > /dev/null << EOF
[Unit]
Description=LandComp App
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$APP_DIR
ExecStart=/usr/local/bin/docker-compose -f $DOCKER_COMPOSE_FILE up -d
ExecStop=/usr/local/bin/docker-compose -f $DOCKER_COMPOSE_FILE down
TimeoutStartSec=0
User=$USER

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable landcomp-app.service
    success "Systemd service created and enabled"
}

# Setup backup script
setup_backup() {
    log "Setting up backup script..."
    
    sudo mkdir -p "$BACKUP_DIR"
    sudo chown $USER:$USER "$BACKUP_DIR"
    
    cat > "$APP_DIR/backup.sh" << EOF
#!/bin/bash
# Backup script for LandComp App

BACKUP_DATE=\$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_\$BACKUP_DATE.tar.gz"

# Create backup
tar -czf "\$BACKUP_FILE" -C "$APP_DIR" .

# Keep only last 7 backups
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete

echo "Backup created: \$BACKUP_FILE"
EOF

    chmod +x "$APP_DIR/backup.sh"
    
    # Add to crontab
    (crontab -l 2>/dev/null; echo "0 2 * * * $APP_DIR/backup.sh") | crontab -
    
    success "Backup script created and scheduled"
}

# Deploy application
deploy_application() {
    log "Deploying application..."
    
    cd "$APP_DIR"
    
    # Login to GitHub Container Registry
    log "Logging in to GitHub Container Registry..."
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_ACTOR" --password-stdin
    
    # Pull latest image
    log "Pulling latest Docker image..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" pull
    
    # Stop existing containers
    log "Stopping existing containers..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" down || true
    
    # Start new containers
    log "Starting new containers..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
    
    # Wait for health check
    log "Waiting for application to be healthy..."
    sleep 30
    
    # Health check
    if curl -f http://localhost/health; then
        success "Application deployed successfully!"
    else
        error "Application health check failed"
        exit 1
    fi
    
    # Clean up old images
    log "Cleaning up old Docker images..."
    docker image prune -f
}

# Main deployment function
main() {
    log "Starting LandComp App deployment..."
    
    check_root
    install_docker
    install_git
    setup_app_directory
    setup_repository
    setup_environment
    create_production_compose
    setup_ssl
    setup_systemd_service
    setup_backup
    
    if [ "$1" = "--deploy" ]; then
        deploy_application
    else
        warning "Setup completed. To deploy the application, run:"
        warning "1. Edit $ENV_FILE with your configuration"
        warning "2. Run: $0 --deploy"
    fi
    
    success "Deployment setup completed!"
}

# Run main function with all arguments
main "$@"
