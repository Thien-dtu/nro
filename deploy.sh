#!/bin/bash

# NRO Offline Server - Complete Deployment Script

# This script automates the deployment of NRO server to your Zorin OS selfhost infrastructure

 

set -e  # Exit on error

 

# Colors for output

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[1;33m'

BLUE='\033[0;34m'

NC='\033[0m' # No Color

 

# Configuration

SELFHOST_DIR="$HOME/Desktop/selthost"

NRO_DIR="$SELFHOST_DIR/nro"

ENV_FILE="$SELFHOST_DIR/.env"

 

echo -e "${BLUE}========================================${NC}"

echo -e "${BLUE}  NRO Offline Server Deployment Script${NC}"

echo -e "${BLUE}========================================${NC}\n"

 

# Function to print steps

print_step() {

    echo -e "${GREEN}[STEP $1]${NC} $2"

}

 

print_warning() {

    echo -e "${YELLOW}[WARNING]${NC} $1"

}

 

print_error() {

    echo -e "${RED}[ERROR]${NC} $1"

}

 

print_success() {

    echo -e "${GREEN}[SUCCESS]${NC} $1"

}

 

# Check if running on correct system

print_step "1" "Checking system requirements..."

 

if ! command -v docker &> /dev/null; then

    print_error "Docker is not installed!"

    exit 1

fi

 

if ! command -v docker-compose &> /dev/null; then

    print_error "Docker Compose is not installed!"

    exit 1

fi

 

print_success "Docker and Docker Compose are installed"

 

# Check if selfhost directory exists

print_step "2" "Checking selfhost directory..."

 

if [ ! -d "$SELFHOST_DIR" ]; then

    print_error "Selfhost directory not found at $SELFHOST_DIR"

    echo "Please update SELFHOST_DIR variable in this script"

    exit 1

fi

 

print_success "Selfhost directory found: $SELFHOST_DIR"

 

# Check if .env file exists

print_step "3" "Checking environment file..."

 

if [ ! -f "$ENV_FILE" ]; then

    print_warning ".env file not found at $ENV_FILE"

    echo "Creating new .env file..."

    touch "$ENV_FILE"

    echo "PUID=1000" >> "$ENV_FILE"

    echo "PGID=1000" >> "$ENV_FILE"

    echo "TZ=America/New_York" >> "$ENV_FILE"

fi

 

print_success "Environment file exists"

 

# Check if NRO environment variables exist

print_step "4" "Checking NRO environment variables..."

 

if ! grep -q "NRO_MYSQL_ROOT_PASSWORD" "$ENV_FILE"; then

    print_warning "NRO MySQL passwords not found in .env"

    echo "Generating secure passwords..."

 

    NRO_MYSQL_ROOT_PW=$(openssl rand -base64 32)

    NRO_MYSQL_PW=$(openssl rand -base64 32)

 

    echo "" >> "$ENV_FILE"

    echo "# NRO Offline Server Configuration" >> "$ENV_FILE"

    echo "NRO_MYSQL_ROOT_PASSWORD=$NRO_MYSQL_ROOT_PW" >> "$ENV_FILE"

    echo "NRO_MYSQL_PASSWORD=$NRO_MYSQL_PW" >> "$ENV_FILE"

 

    print_success "Generated and added MySQL passwords to .env"

    echo -e "${YELLOW}Please save these passwords:${NC}"

    echo "Root password: $NRO_MYSQL_ROOT_PW"

    echo "User password: $NRO_MYSQL_PW"

else

    print_success "NRO environment variables already configured"

fi

 

# Clone/copy repository

print_step "5" "Setting up NRO directory..."

 

if [ -d "$NRO_DIR" ]; then

    print_warning "NRO directory already exists at $NRO_DIR"

    read -p "Do you want to remove and re-clone? (y/N): " -n 1 -r

    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then

        rm -rf "$NRO_DIR"

        print_success "Removed existing directory"

    else

        print_warning "Using existing directory"

    fi

fi

 

if [ ! -d "$NRO_DIR" ]; then

    echo "Cloning repository..."

    cd "$SELFHOST_DIR"

    git clone https://github.com/Thien-dtu/nro-offline.git nro

    cd nro

    git checkout claude/define-project-purpose-018SJAhXmvyN3b5c6Vq1D4Mx

    print_success "Repository cloned successfully"

else

    cd "$NRO_DIR"

    print_success "Using existing repository"

fi

 

# Check if selfnet network exists

print_step "6" "Checking Docker network..."

 

if ! docker network ls | grep -q "selfnet"; then

    print_warning "selfnet network not found, creating it..."

    docker network create selfnet

    print_success "Created selfnet network"

else

    print_success "selfnet network exists"

fi

 

# Validate docker-compose.yml

print_step "7" "Validating Docker Compose configuration..."

 

if docker-compose config > /dev/null 2>&1; then

    print_success "Docker Compose configuration is valid"

else

    print_error "Docker Compose configuration has errors"

    docker-compose config

    exit 1

fi

 

# Create data directories

print_step "8" "Creating data directories..."

 

mkdir -p "$NRO_DIR/data/nro-mysql"

mkdir -p "$NRO_DIR/data/nro-server/NRO-Server"

mkdir -p "$NRO_DIR/data/nro-server/data"

 

# Set proper permissions

sudo chown -R $(id -u):$(id -g) "$NRO_DIR/data"

 

print_success "Data directories created with proper permissions"

 

# Build and start containers

print_step "9" "Building Docker images..."

 

echo "This may take a few minutes..."

docker-compose build

 

print_success "Docker images built successfully"

 

print_step "10" "Starting containers..."

 

docker-compose up -d

 

print_success "Containers started"

 

# Wait for containers to be healthy

print_step "11" "Waiting for MySQL to be ready..."

 

echo "Waiting for MySQL container to be healthy (this may take 30-60 seconds)..."

timeout=60

counter=0

 

while [ $counter -lt $timeout ]; do

    if docker inspect nro-mysql 2>/dev/null | grep -q '"Status": "healthy"'; then

        print_success "MySQL is healthy and ready"

        break

    fi

    echo -n "."

    sleep 2

    counter=$((counter + 2))

done

 

if [ $counter -ge $timeout ]; then

    print_error "MySQL did not become healthy in time"

    echo "Check logs with: docker-compose logs nro-mysql"

    exit 1

fi

 

# Show container status

print_step "12" "Checking container status..."

 

echo ""

docker-compose ps

echo ""

 

# Get MySQL password for next steps

NRO_MYSQL_PASSWORD=$(grep NRO_MYSQL_PASSWORD "$ENV_FILE" | cut -d '=' -f 2)

 

# Print next steps

echo -e "${BLUE}========================================${NC}"

echo -e "${GREEN}✅ Deployment Complete!${NC}"

echo -e "${BLUE}========================================${NC}\n"

 

echo -e "${YELLOW}📋 NEXT STEPS:${NC}\n"

 

echo -e "${GREEN}1. Initial Server Setup${NC}"

echo "   Run the setup menu:"

echo -e "   ${BLUE}cd $NRO_DIR${NC}"

echo -e "   ${BLUE}docker-compose exec nro-server python3 nro_deobfuscated.py${NC}"

echo ""

echo "   Then choose:"

echo "   - Option 1: Download and install server"

echo "   - Option 2: Download and import SQL"

echo "     MySQL credentials:"

echo "     - Host: nro-mysql"

echo "     - User: nro_user"

echo "     - Password: $NRO_MYSQL_PASSWORD"

echo "     - Port: 3306"

echo "   - Option 3: Start server"

echo ""

 

echo -e "${GREEN}2. Connect to Server${NC}"

echo "   Your server will be accessible on your local network at:"

echo -e "   ${BLUE}$(hostname -I | awk '{print $1}'):14445${NC}"

echo ""

 

echo -e "${GREEN}3. Monitor Logs${NC}"

echo -e "   ${BLUE}docker-compose logs -f nro-server${NC}"

echo ""

 

echo -e "${GREEN}4. Access Portainer${NC}"

echo "   Manage containers via your existing Portainer instance"

echo ""

 

echo -e "${YELLOW}⚠️  SECURITY REMINDERS:${NC}"

echo "   - Review SECURITY_ANALYSIS.md before running"

echo "   - Inspect downloaded files before executing"

echo "   - Monitor server logs for suspicious activity"

echo "   - Keep to local network only unless using Cloudflare Tunnel"

echo ""

 

echo -e "${BLUE}========================================${NC}"

echo -e "${GREEN}📚 Documentation:${NC}"

echo "   - Setup Guide: $NRO_DIR/DOCKER.md"

echo "   - Security Analysis: $NRO_DIR/SECURITY_ANALYSIS.md"

echo "   - Original README: $NRO_DIR/README.md"

echo -e "${BLUE}========================================${NC}\n"

 

print_success "Deployment script completed successfully!"