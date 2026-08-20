#!/bin/bash
sudo apt-get update
sudo apt-get install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
echo "<h2> Nginx is installed and running!</h2>" | sudo tee /var/www/html/index.html