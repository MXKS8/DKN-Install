#!/bin/bash

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check command status
check_status() {
    if [ $? -ne 0 ]; then
        log "Error: $1"
        exit 1
    fi
}

# Check if running with sudo privileges
if [ "$EUID" -ne 0 ]; then
    log "Please run with sudo privileges"
    exit 1
}

# Navigate to home directory
cd ~
log "Installing required packages..."

# Install needed packages
apt-get update
check_status "Failed to update package list"

# Install required packages
apt-get install -y unzip wget curl git tmux
check_status "Failed to install required packages"

# Download DKN Compute Node
log "Setting up DKN Compute Node..."
if [ ! -d "dkn-compute-node" ]; then
    git clone https://github.com/firstbatchxyz/dkn-compute-node.git
    check_status "Failed to clone DKN Compute Node repository"
else
    cd dkn-compute-node
    git pull
    check_status "Failed to update DKN Compute Node repository"
    cd ~
fi

# Install Ollama
log "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
check_status "Failed to install Ollama"

# Download DKN Compute Launcher
log "Downloading DKN Compute Launcher..."
wget -q https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-linux-amd64.zip
check_status "Failed to download DKN Compute Launcher"

# Unzip DKN Compute Launcher
unzip -o dkn-compute-launcher-linux-amd64.zip
check_status "Failed to unzip DKN Compute Launcher"

# Ask user for OPENAI_API_KEY with validation
while true; do
    read -p "Enter your OPENAI_API_KEY: " OPENAI_API_KEY
    if [[ $OPENAI_API_KEY =~ ^sk-[a-zA-Z0-9]{48}$ ]]; then
        break
    else
        log "Invalid API key format. It should start with 'sk-' and be 51 characters long."
    fi
done

# Update existing .env file
if [ -f ~/dkn-compute-node/.env ]; then
    sed -i "s|^OPENAI_API_KEY=.*|OPENAI_API_KEY=$OPENAI_API_KEY|" ~/dkn-compute-node/.env
    check_status "Failed to update .env file"
else
    echo "OPENAI_API_KEY=$OPENAI_API_KEY" > ~/dkn-compute-node/.env
    check_status "Failed to create .env file"
fi

# Pull Ollama model
log "Pulling Ollama model..."
ollama pull hellord/mxbai-embed-large-v1:f16
check_status "Failed to pull Ollama model"

# Kill existing DRIA session if it exists
if tmux has-session -t DRIA 2>/dev/null; then
    log "Killing existing DRIA session..."
    tmux kill-session -t DRIA
fi

# Start a new tmux session
log "Starting DRIA session..."
tmux new-session -d -s DRIA
check_status "Failed to create tmux session"

# Send commands to the tmux session
tmux send-keys -t DRIA "cd ~/dkn-compute-node && ./dkn-compute-launcher" C-m
sleep 1
tmux send-keys -t DRIA "" C-m
sleep 1
tmux send-keys -t DRIA "" C-m

log "Installation complete! To attach to the DRIA session, use: tmux attach -t DRIA"
