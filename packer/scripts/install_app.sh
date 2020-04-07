#!/bin/bash
set -e

# Clone App
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install

# Start App
echo "Copy puma service file"
cp /tmp/puma.service /etc/systemd/system/puma.service
echo "Start Puma"
systemctl start puma
echo "Enable Puma"
systemctl enable puma
