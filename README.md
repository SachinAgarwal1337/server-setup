# EC2 Bootstrap

This repository contains a simple bootstrap script to prepare a fresh Ubuntu EC2 instance for development and container workloads.

Files

- ec2-bootstrap.sh: interactive bootstrap script that installs updates, base utilities, optional swap, and Docker (including Docker Compose plugin).

Quick overview

- The script is interactive for swap configuration and will add your user to the `docker` group when Docker is installed. It uses `apt` and assumes an Ubuntu-based AMI.

Prerequisites

- An Ubuntu EC2 instance (20.04, 22.04, or later).
- A user with sudo privileges (default `ubuntu` or `ec2-user` depending on AMI).
- SSH access to the instance.

Steps to run on an EC2 instance

1. Upload the script to the instance (from your local machine):

```bash
scp -i /path/to/key.pem ec2-bootstrap.sh ubuntu@EC2_PUBLIC_IP:~/
```

2. SSH into the instance:

```bash
ssh -i /path/to/key.pem ubuntu@EC2_PUBLIC_IP
```

3. Make the script executable and review it (recommended):

```bash
chmod +x ec2-bootstrap.sh
less ec2-bootstrap.sh
```

4. Run the script. Recommended safe option for a fresh server is `all`:

```bash
sudo ./ec2-bootstrap.sh all
```

Notes and examples

- To run only specific tasks use the subcommands: `update`, `utils`, `swap`, or `docker`.
- The script will prompt before creating swap space. Enter an integer size in GB (for example `2`) when prompted.
- If the script adds your SSH user to the `docker` group, you must log out and log back in (or restart the session) for the group change to take effect.

Verification

- Check Docker is running and you can run `hello-world`:

```bash
docker run --rm hello-world
```

- Check swap is active (if configured):

```bash
swapon --show
free -h
```

Troubleshooting

- If `apt` hangs or fails, try running `sudo apt update` then re-run the script.
- If Docker services don't start: check `sudo systemctl status docker` and inspect logs with `sudo journalctl -u docker --no-pager`.
- If the `docker` command fails with permission denied after the script says it added your user to the group, sign out and back in or reboot the instance.

Security notes

- The script uses `sudo` and modifies system packages. Review before running on production systems.
- The script appends a `/swapfile` entry to `/etc/fstab` when swap is created.

Want me to also create a non-interactive mode or a systemd service for Docker containers? Ask and I can add that.
Download from GitHub

---

If you host this repository on GitHub (or any Git host that provides raw file URLs), you can download `ec2-bootstrap.sh` directly to an EC2 instance.

1. Using `curl` (recommended for single-file download):

```bash
curl -o ec2-bootstrap.sh -L https://raw.githubusercontent.com/<OWNER>/<REPO>/<BRANCH>/ec2-bootstrap.sh
chmod +x ec2-bootstrap.sh
```

2. Using `wget`:

```bash
wget -O ec2-bootstrap.sh https://raw.githubusercontent.com/<OWNER>/<REPO>/<BRANCH>/ec2-bootstrap.sh
chmod +x ec2-bootstrap.sh
```

3. Clone the repo if you want the full project:

```bash
git clone https://github.com/<OWNER>/<REPO>.git
cd <REPO>
chmod +x ec2-bootstrap.sh
```

Checksum verification (optional)

- After downloading, you can verify the file integrity if you publish a checksum in your release notes. Example to check SHA256:

```bash
sha256sum ec2-bootstrap.sh  # compare with published checksum
```

Replace `<OWNER>`, `<REPO>`, and `<BRANCH>` with your GitHub username, repository name, and branch (often `main`).

Now run the script as shown above (for example `sudo ./ec2-bootstrap.sh all`).
