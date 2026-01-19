#!/bin/bash
sudo dnf update -y
sudo dnf install -y nginx
sudo echo "<h1>Hello, welcome to the cloud hello</h1>" | sudo tee /usr/share/nginx/html/index.html
sudo systemctl enable nginx
sudo systemctl start nginx