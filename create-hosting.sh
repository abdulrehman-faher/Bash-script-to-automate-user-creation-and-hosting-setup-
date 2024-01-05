#!/bin/bash

# Get user input for username and domain
read -p "Enter username: " username
read -p "Enter custom domain (without www): " domain

# Install required software
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx -y

# Create user account
sudo adduser $username

# Create website directory
sudo mkdir -p /var/www/$username/public_html
sudo chown -R $username:$username /var/www/$username

# Configure Nginx virtual host
sudo tee /etc/nginx/sites-available/$username.conf <<EOF
server {
    listen 80;
    server_name $domain;
    root /var/www/$username/public_html;
    index index.html;
}
EOF

# Activate configuration and reload Nginx
sudo ln -s /etc/nginx/sites-available/$username.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Obtain SSL certificate
sudo certbot --nginx -d $domain

# Remind user to set up DNS records
echo "Don't forget to point the domain '$domain' to this server's IP address using A records in your DNS settings."
