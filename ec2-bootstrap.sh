#!/usr/bin/env bash
set -e

# ------------------------
# Helpers
# ------------------------
ask_yes_no() {
  local PROMPT=$1
  local RESPONSE
  while true; do
    read -p "$PROMPT (y/n): " RESPONSE
    case "$RESPONSE" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

print_header() {
  echo
  echo "========================================"
  echo " $1"
  echo "========================================"
}

# ------------------------
# Tasks
# ------------------------

task_update() {
  print_header "Updating system packages"
  sudo apt update -y
  sudo apt upgrade -y
}

task_utils() {
  print_header "Installing base utilities"
  sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    unzip \
    git \
    htop
}

task_swap() {
  print_header "Swap configuration"

  if ! ask_yes_no "Do you want to configure swap?"; then
    echo "Skipping swap setup."
    return
  fi

  read -p "Enter swap size in GB (e.g. 2): " SWAP_SIZE

  if [[ -z "$SWAP_SIZE" || ! "$SWAP_SIZE" =~ ^[0-9]+$ ]]; then
    echo "Invalid swap size. Aborting swap setup."
    return
  fi

  if swapon --show | grep -q swapfile; then
    echo "Swap already exists. Skipping."
    return
  fi

  echo "Creating ${SWAP_SIZE}GB swap file..."
  sudo fallocate -l "${SWAP_SIZE}G" /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

  echo "Swap configured successfully."
}

task_docker() {
  print_header "Docker installation"

  if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed."
  else
    echo "Installing Docker..."

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update -y
    sudo apt install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl start docker

    echo "Docker installed successfully."
  fi

  if ! groups "$USER" | grep -q docker; then
    echo "Adding user to docker group..."
    sudo usermod -aG docker "$USER"
    echo "⚠️  Log out and back in for docker group changes to apply."
  else
    echo "User already in docker group."
  fi
}

task_all() {
  task_update
  task_utils
  task_swap
  task_docker
}

print_help() {
  echo
  echo "Usage:"
  echo "  $0 <command>"
  echo
  echo "Commands:"
  echo "  all        Run full bootstrap (recommended for new EC2)"
  echo "  update     Update system packages"
  echo "  utils      Install base utilities"
  echo "  swap       Configure swap"
  echo "  docker     Install Docker and Docker Compose"
  echo "  help       Show this help"
  echo
}

# ------------------------
# Command router
# ------------------------

COMMAND=$1

case "$COMMAND" in
  all)
    task_all
    ;;
  update)
    task_update
    ;;
  utils)
    task_utils
    ;;
  swap)
    task_swap
    ;;
  docker)
    task_docker
    ;;
  help|"")
    print_help
    ;;
  *)
    echo "Unknown command: $COMMAND"
    print_help
    exit 1
    ;;
esac

echo
echo "Bootstrap task '$COMMAND' completed."
