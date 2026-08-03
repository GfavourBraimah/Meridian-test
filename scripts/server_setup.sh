#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e 

# Run everything non-interactive so the boot process doesn't get stuck asking for "Y/n"
export DEBIAN_FRONTEND=noninteractive

echo "Starting server configuration for Meridian Retail..."

# 1. Update and Upgrade packages sharp sharp
apt-get update -y
apt-get upgrade -y

# 2. Install basic utilities and AWS CLI (Super important so your EC2 can login to ECR to pull images)
apt-get install -y curl wget git unzip jq awscli postgresql-client cron

# 3. Install Docker & Docker Compose Plugin
# First, add Docker's official GPG key and repo
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker to start automatically whenever the server reboots
systemctl enable docker
systemctl start docker

# MASSIVE SECURITY FIX: Add the 'ubuntu' user to the docker group
# If we don't do this, GitHub Actions will crash when trying to run docker commands because it won't have sudo access!
usermod -aG docker ubuntu

# 4. Install Nginx and Certbot (For the Reverse Proxy and HTTPS/TLS objectives)
apt-get install -y nginx certbot python3-certbot-nginx

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx

# 5. Create project directories and set ownership so GitHub Actions SCP doesn't get Permission Denied
mkdir -p /home/ubuntu/meridian-retail/scripts
mkdir -p /home/ubuntu/meridian-retail/backups
mkdir -p /home/ubuntu/meridian-retail/nginx
chown -R ubuntu:ubuntu /home/ubuntu/meridian-retail

# 6. Automate the daily PostgreSQL backup via cron (Runs every day at 2:00 AM)
# This hits the Amdari objective to prove the backup is automated!
echo "0 2 * * * root /bin/bash /home/ubuntu/meridian-retail/scripts/backup_db.sh >> /var/log/cron_backup.log 2>&1" > /etc/cron.d/meridian-backup
chmod 0644 /etc/cron.d/meridian-backup
systemctl restart cron

# Copy config to Nginx system folder
sudo cp /home/${{ secrets.EC2_USERNAME }}/meridian-retail/nginx/meridian-http.conf /etc/nginx/sites-available/meridian

# Enable the site and remove the default Nginx welcome page
sudo ln -sf /etc/nginx/sites-available/meridian /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
sudo nginx -t
sudo systemctl reload nginx


docker compose pull
docker compose up -d

            # 🚀 GET THE PADLOCK: Provision TLS certificate via Certbot HTTP-01 challenge
sudo certbot --nginx -d shop-meridian.duckdns.org --non-interactive --agree-tos -m bogreaper05@gmail.com --redirect --keep-until-expiring

echo "Server setup completed successfully! The EC2 is fully cooked and ready for GitHub Actions."