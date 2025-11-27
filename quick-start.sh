#!/bin/bash

# Prossima AI - Quick Start Script
# Prossimagen Technologies
# This script automates the setup process for team members

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Prossima AI Banner
echo -e "${PURPLE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║                    🚀 PROSSIMA AI 🚀                          ║"
echo "║             Enterprise Visual Agent Builder                   ║"
echo "║                                                               ║"
echo "║           Powered by Prossimagen Technologies                 ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_step() {
    echo -e "${PURPLE}▶ $1${NC}"
}

# Check if Docker is installed and running
check_docker() {
    print_step "Checking Docker installation..."

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        echo ""
        echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker is not running!"
        echo ""
        echo "Please start Docker Desktop and try again."
        exit 1
    fi

    print_success "Docker is installed and running"
}

# Check if docker-compose is available
check_docker_compose() {
    print_step "Checking Docker Compose..."

    if ! docker-compose --version &> /dev/null; then
        print_error "Docker Compose is not available!"
        echo ""
        echo "Please ensure Docker Desktop is properly installed."
        exit 1
    fi

    print_success "Docker Compose is available"
}

# Check disk space (minimum 10GB free)
check_disk_space() {
    print_step "Checking available disk space..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        available=$(df -g . | tail -1 | awk '{print $4}')
    else
        # Linux
        available=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
    fi

    if [ "$available" -lt 10 ]; then
        print_warning "Low disk space detected (${available}GB available)"
        print_info "Recommended: At least 10GB free space"
    else
        print_success "Sufficient disk space available (${available}GB)"
    fi
}

# Setup .env file
setup_env() {
    print_step "Setting up environment configuration..."

    if [ -f "deploy/docker/.env" ]; then
        print_warning ".env file already exists"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Keeping existing .env file"
            return
        fi
    fi

    if [ ! -f "deploy/docker/.env.example" ]; then
        print_error ".env.example not found!"
        exit 1
    fi

    cp deploy/docker/.env.example deploy/docker/.env
    print_success "Created .env file from template"

    echo ""
    print_warning "⚠️  IMPORTANT: You need to configure your API key!"
    echo ""
    echo "Please edit deploy/docker/.env and add your API key:"
    echo ""
    echo "  Option 1 (Recommended): OpenRouter"
    echo "    OPENAI_API_KEY=sk-or-v1-YOUR_KEY_HERE"
    echo "    OPENAI_API_BASE=https://openrouter.ai/api/v1"
    echo "    OPENAI_MODEL_NAME=openai/gpt-4o-mini"
    echo ""
    echo "  Option 2: OpenAI Direct"
    echo "    OPENAI_API_KEY=sk-YOUR_OPENAI_KEY"
    echo "    OPENAI_API_BASE=https://api.openai.com/v1"
    echo "    OPENAI_MODEL_NAME=gpt-4o-mini"
    echo ""

    read -p "Press Enter to open .env file in default editor..." -r

    if [[ "$OSTYPE" == "darwin"* ]]; then
        open deploy/docker/.env
    elif command -v xdg-open &> /dev/null; then
        xdg-open deploy/docker/.env
    else
        ${EDITOR:-nano} deploy/docker/.env
    fi

    echo ""
    read -p "Have you added your API key? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Please configure your API key before starting the application"
        exit 1
    fi
}

# Start Docker services
start_services() {
    print_step "Starting Prossima AI services..."
    echo ""
    print_info "This may take 2-3 minutes on first run (downloading images)..."
    echo ""

    docker-compose -f deploy/docker/docker-compose.dev.yml up -d

    print_success "Services started successfully!"
}

# Wait for services to be ready
wait_for_services() {
    print_step "Waiting for services to initialize..."

    max_attempts=60
    attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:5001/api/health > /dev/null 2>&1; then
            print_success "Backend API is ready"
            break
        fi

        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done

    echo ""

    if [ $attempt -eq $max_attempts ]; then
        print_warning "Backend took longer than expected to start"
        print_info "Check logs with: docker-compose -f deploy/docker/docker-compose.dev.yml logs backend"
    fi

    # Wait a bit more for frontend
    sleep 5
}

# Show service status
show_status() {
    echo ""
    print_step "Service Status:"
    echo ""
    docker-compose -f deploy/docker/docker-compose.dev.yml ps
    echo ""
}

# Show access information
show_access_info() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                   🎉 SETUP COMPLETE! 🎉                        ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    print_success "Prossima AI is now running!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  🌐  Frontend:        http://localhost:5173"
    echo "  🔧  Backend API:     http://localhost:5001"
    echo "  🔐  Keycloak Admin:  http://localhost:8081"
    echo "  📊  PgAdmin:         http://localhost:8002"
    echo "  💾  Redis Insight:   http://localhost:8001"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  Default Login:"
    echo "    Username: admin"
    echo "    Password: admin"
    echo ""
    echo "  ⚠️  Change the password after first login!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_info "Useful commands:"
    echo ""
    echo "  View logs:"
    echo "    docker-compose -f deploy/docker/docker-compose.dev.yml logs -f"
    echo ""
    echo "  Stop services:"
    echo "    docker-compose -f deploy/docker/docker-compose.dev.yml down"
    echo ""
    echo "  Restart services:"
    echo "    docker-compose -f deploy/docker/docker-compose.dev.yml restart"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_success "Happy building with Prossima AI! 🚀"
    echo ""
}

# Main execution
main() {
    check_docker
    check_docker_compose
    check_disk_space

    echo ""

    setup_env

    echo ""

    start_services

    wait_for_services

    show_status

    show_access_info

    # Open browser (optional)
    echo ""
    read -p "Open Prossima AI in browser? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open http://localhost:5173
        elif command -v xdg-open &> /dev/null; then
            xdg-open http://localhost:5173
        else
            print_info "Please open http://localhost:5173 in your browser"
        fi
    fi
}

# Run main function
main
