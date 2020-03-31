#!/bin/bash
echo "Download project's code"
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
echo 'Start puma-server'
puma -d
