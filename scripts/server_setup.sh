#!/bin/bash
set -e 
export DEBIAN_FRONTEND=noninteractive

echo "Starting server configuration for Meridian Retail..."

# 1. Update and Upgrade packages
apt-get update -y
apt-get upgrade -y

# 2. Install basic utilities and AWS CLI
apt-get install -y curl wget git unzip jq awscli postgresql-client cron

# 3. Install Docker & Docker Compose Plugin
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# 4. Install Nginx and Certbot
apt-get install -y nginx certbot python3-certbot-nginx
systemctl enable nginx
systemctl start nginx

# 5. Create project directories
mkdir -p /home/ubuntu/meridian-retail/scripts
mkdir -p /home/ubuntu/meridian-retail/backups
mkdir -p /home/ubuntu/meridian-retail/nginx
chown -R ubuntu:ubuntu /home/ubuntu/meridian-retail

# 6. Automate daily PostgreSQL backup via cron
echo "0 2 * * * root /bin/bash /home/ubuntu/meridian-retail/scripts/backup_db.sh >> /var/log/cron_backup.log 2>&1" > /etc/cron.d/meridian-backup
chmod 0644 /etc/cron.d/meridian-backup
systemctl restart cron

echo "Server infrastructure bootstrapping completed successfully!"