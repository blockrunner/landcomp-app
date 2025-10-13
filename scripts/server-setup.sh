#!/bin/bash

# LandComp App Server Setup Script
# This script prepares the Ubuntu server for deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="landcomp-app"
APP_DIR="/home/landcomp-app"
USER_NAME="tonybreza"
GIT_REPO="git@github.com:blockrunner/landcomp-app.git"

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

# Check if running as tonybreza user
check_user() {
    if [[ "$USER" != "$USER_NAME" ]]; then
        error "This script should be run as user: $USER_NAME"
        error "Current user: $USER"
        exit 1
    fi
}

# Update system packages
update_system() {
    log "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    success "System packages updated"
}

# Install Docker
install_docker() {
    log "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        success "Docker is already installed"
        return
    fi
    
    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    
    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    success "Docker and Docker Compose installed successfully"
    warning "Please log out and log back in for Docker group changes to take effect"
}

# Install Git
install_git() {
    log "Installing Git..."
    
    if command -v git &> /dev/null; then
        success "Git is already installed"
        return
    fi
    
    sudo apt install -y git
    success "Git installed successfully"
}

# Install additional tools
install_tools() {
    log "Installing additional tools..."
    
    sudo apt install -y curl wget nano htop tree unzip
    success "Additional tools installed"
}

# Create application directory
create_app_directory() {
    log "Creating application directory..."
    
    if [ -d "$APP_DIR" ]; then
        warning "Application directory already exists: $APP_DIR"
        return
    fi
    
    mkdir -p "$APP_DIR"
    success "Application directory created: $APP_DIR"
}

# Setup SSH key for GitHub
setup_github_ssh() {
    log "Setting up GitHub SSH access..."
    
    if [ ! -f ~/.ssh/id_ed25519_github ]; then
        warning "GitHub SSH key not found. Please ensure tonybreza_deploy key is available"
        warning "Copy the private key to ~/.ssh/tonybreza_deploy"
        return
    fi
    
    # Create SSH config for GitHub
    cat > ~/.ssh/config << EOF
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/tonybreza_deploy
    IdentitiesOnly yes
EOF
    
    chmod 600 ~/.ssh/config
    success "GitHub SSH configuration created"
}

# Clone repository
clone_repository() {
    log "Cloning repository..."
    
    if [ -d "$APP_DIR/.git" ]; then
        warning "Repository already exists in $APP_DIR"
        return
    fi
    
    cd "$APP_DIR"
    git clone "$GIT_REPO" .
    success "Repository cloned successfully"
}

# Setup environment file
setup_environment() {
    log "Setting up environment configuration..."
    
    if [ -f "$APP_DIR/.env" ]; then
        warning "Environment file already exists"
        return
    fi
    
    if [ -f "$APP_DIR/env.example" ]; then
        cp "$APP_DIR/env.example" "$APP_DIR/.env"
        warning "Environment file created from template"
        warning "Please edit $APP_DIR/.env with your actual values"
    else
        error "Environment template not found"
        exit 1
    fi
}

# Setup logging directory
setup_logging() {
    log "Setting up logging directory..."
    
    mkdir -p "$APP_DIR/logs"
    chmod 755 "$APP_DIR/logs"
    success "Logging directory created"
}

# Setup backup script
setup_backup() {
    log "Setting up backup script..."
    
    cat > "$APP_DIR/backup.sh" << 'EOF'
#!/bin/bash
# Backup script for LandComp App

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/tonybreza/backups"
BACKUP_FILE="$BACKUP_DIR/landcomp_backup_$BACKUP_DATE.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create backup
tar -czf "$BACKUP_FILE" -C /home/landcomp-app .

# Keep only last 7 backups
find "$BACKUP_DIR" -name "landcomp_backup_*.tar.gz" -mtime +7 -delete

echo "Backup created: $BACKUP_FILE"
EOF
    
    chmod +x "$APP_DIR/backup.sh"
    
    # Add to crontab
    (crontab -l 2>/dev/null; echo "0 2 * * * $APP_DIR/backup.sh") | crontab -
    
    success "Backup script created and scheduled"
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
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
TimeoutStartSec=0
User=$USER_NAME

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable landcomp-app.service
    success "Systemd service created and enabled"
}

# Test Docker installation
test_docker() {
    log "Testing Docker installation..."
    
    if docker --version && docker-compose --version; then
        success "Docker and Docker Compose are working correctly"
    else
        error "Docker installation test failed"
        exit 1
    fi
}

# Main setup function
main() {
    log "Starting LandComp App server setup..."
    
    check_user
    update_system
    install_docker
    install_git
    install_tools
    create_app_directory
    setup_github_ssh
    clone_repository
    setup_environment
    setup_logging
    setup_backup
    setup_systemd_service
    test_docker
    
    success "Server setup completed successfully!"
    
    warning "Next steps:"
    warning "1. Edit $APP_DIR/.env with your actual configuration values"
    warning "2. Test SSH connection to GitHub: ssh -T git@github.com"
    warning "3. Run deployment: cd $APP_DIR && docker-compose -f docker-compose.prod.yml up -d"
    warning "4. Check application: curl http://localhost/health"
}

# Run main function with all arguments
main "$@"
