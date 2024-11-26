#!/bin/bash
# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to show progress
show_status() {
    echo -e "${YELLOW}⏳ $1...${NC}"
}

# Function to show success
show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to show error
show_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Function to show info
show_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Function to check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    show_error "Please run as root (use sudo)"
fi

# Navigate to home directory
cd ~

# Install required packages
show_status "Installing required packages"
apt-get update || show_error "Failed to update package list"
apt-get install -y unzip wget curl git tmux || show_error "Failed to install required packages"
show_success "Required packages installed"

# Install Ollama
show_status "Installing Ollama"
if ! command_exists ollama; then
    curl -fsSL https://ollama.com/install.sh | sh || show_error "Failed to install Ollama"
    show_success "Ollama installed"
else
    show_success "Ollama already installed"
fi

# Download DKN Compute Node
show_status "Setting up DKN Compute Node"
if [ ! -d "dkn-compute-node" ]; then
    git clone https://github.com/firstbatchxyz/dkn-compute-node.git || show_error "Failed to clone DKN Compute Node"
else
    cd dkn-compute-node
    git pull || show_error "Failed to update DKN Compute Node"
    cd ~
fi
show_success "DKN Compute Node setup complete"

# Download DKN Compute Launcher
show_status "Downloading DKN Compute Launcher"
wget -q https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-linux-amd64.zip || show_error "Failed to download launcher"
show_success "Launcher downloaded"

# Unzip DKN Compute Launcher
show_status "Extracting launcher"
unzip -o dkn-compute-launcher-linux-amd64.zip || show_error "Failed to extract launcher"
show_success "Launcher extracted"

# Pull Ollama model
show_status "Pulling Ollama model"
ollama pull hellord/mxbai-embed-large-v1:f16 || show_error "Failed to pull Ollama model"
show_success "Ollama model pulled"

# Check if TMUX session exists
if tmux has-session -t DRIA 2>/dev/null; then
    show_status "Killing existing DRIA session"
    tmux kill-session -t DRIA
fi

# Make launcher executable
chmod +x ~/dkn-compute-node/dkn-compute-launcher || show_error "Failed to make launcher executable"

# Start TMUX session and automatically attach
show_status "Starting and attaching to DRIA session"
cd ~/dkn-compute-node
tmux new-session -s DRIA './dkn-compute-launcher' || show_error "Failed to create and attach to TMUX session"

# Note: The script will stop here as we're now in the attached tmux session
# The following echo statements will only be seen if the tmux session is detached or closed

show_success "Installation completed successfully!"
echo ""
echo -e "${BLUE}📝 Important notes:${NC}"
echo "  - You are now in the TMUX session 'DRIA'"
echo "  - To detach from session: Press Ctrl+B, then D"
echo "  - To reattach later: tmux attach -t DRIA"
echo "  - To view sessions: tmux ls"
echo ""
show_info "DKN node is now running in the current session"
