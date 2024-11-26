#!/bin/bash

# Navigate to home directory
cd ~

# Install needed packages
sudo apt-get update
sudo apt-get install -y unzip wget curl git

# Download DKN Compute Node
if [ ! -d "dkn-compute-node" ]; then
  git clone https://github.com/firstbatchxyz/dkn-compute-node.git
else
  cd dkn-compute-node
  git pull
  cd ~
fi

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Download DKN Compute Launcher
wget https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-linux-amd64.zip

# Unzip DKN Compute Launcher
unzip -o dkn-compute-launcher-linux-amd64.zip

# Ask user for OPENAI_API_KEY
read -p "Enter your OPENAI_API_KEY: " OPENAI_API_KEY

# Update existing .env file in ~/dkn-compute-node with environment variables
sed -i "s|^OPENAI_API_KEY=.*|OPENAI_API_KEY=$OPENAI_API_KEY|" ~/dkn-compute-node/.env

# Pull Ollama model
ollama pull hellord/mxbai-embed-large-v1:f16

# Start a tmux session named DRIA and run DKN Compute Launcher in it
tmux new -s DRIA '~/dkn-compute-node/./dkn-compute-launcher'

# Send two enters to skip questions
sleep 1
tmux send-keys -t DRIA "" C-m
sleep 1
tmux send-keys -t DRIA "" C-m
