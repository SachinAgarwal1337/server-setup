**EC2 Bootstrap: Ubuntu Server Setup**

This repository contains a simple, reliable bootstrap script for initializing a fresh Ubuntu server (e.g., an EC2 instance). The script installs base utilities, configures optional swap, and installs Docker using the official Docker repository.

- Script: [ec2-bootstrap.sh](ec2-bootstrap.sh)

**Requirements**

- Ubuntu server with `apt` (tested on modern Ubuntu LTS images).
- A sudo-capable user (the script uses `sudo`).
- Internet access to reach Ubuntu and Docker repositories.

**Quick Start**
Download directly from GitHub, make it executable, then run a command:

```bash
curl -fsSL -o ec2-bootstrap.sh https://raw.githubusercontent.com/SachinAgarwal1337/server-setup/main/ec2-bootstrap.sh
```

```bash
chmod +x ec2-bootstrap.sh
./ec2-bootstrap.sh help
```

To run the full setup recommended for new EC2 instances:

```bash
./ec2-bootstrap.sh all
```

You can also run individual tasks:

```bash
./ec2-bootstrap.sh update    # Update and upgrade packages
./ec2-bootstrap.sh utils     # Install base utilities
./ec2-bootstrap.sh swap      # Interactive swap setup
./ec2-bootstrap.sh docker    # Install Docker + add user to docker group
```

**What the Script Does**

- **`update`:** Runs `apt update -y` and `apt upgrade -y` to bring the system current.
- **`utils`:** Installs common utilities: `ca-certificates`, `curl`, `gnupg`, `lsb-release`, `unzip`, `git`, `htop`.
- **`swap`:**
  - Prompts whether to configure swap.
  - Asks for swap size in GB and validates input.
  - Skips if a swapfile already exists.
  - Creates `/swapfile`, sets correct permissions, enables it, and appends an `/etc/fstab` entry for persistence.
- **`docker`:**
  - Installs Docker from the official Docker APT repository (adds keyring and repo).
  - Installs `docker-ce`, CLI, `containerd`, Buildx, and Docker Compose plugin.
  - Enables and starts the Docker service.
  - If needed, adds the current user to the `docker` group and reminds you to re-login for group changes to take effect.
- **`all`:** Runs `update` → `utils` → `swap` → `docker` in sequence.

**Behavior and Notes**

- The script runs with `set -e` and will exit on the first error.
- Re-running is safe: it skips Docker install if already present and detects existing swap.
- The `swap` step is interactive; you can choose to skip it.
- After `docker` adds your user to the `docker` group, you must log out and back in (or start a new session) for group membership to apply.

**Verification**
After the script completes:

```bash
# Docker
docker --version
docker run --rm hello-world

# Swap
swapon --show

# Utilities
git --version
htop --version || htop --help
```

**Troubleshooting**

- If `docker` commands require `sudo` after running `docker` task, start a new login session or reboot to apply group changes.
- Ensure outbound HTTPS access is allowed to reach Docker and Ubuntu repositories.
- If using a non-Ubuntu distro, this script may not apply (it relies on `apt`).

**Usage Summary**

- Full bootstrap for new servers: `./ec2-bootstrap.sh all`
- See available commands and descriptions: `./ec2-bootstrap.sh help`
