#!/bin/bash
set -e

APP_DIR=${1:-$HOME}/reddit

git clone -b monolith https://github.com/express42/reddit.git $APP_DIR
cd /home/appuser/reddit
bundle install

sudo mv /tmp/puma.service /etc/systemd/system/puma.service
sudo systemctl daemon-reload
sudo systemctl restart puma
sudo systemctl enable puma
