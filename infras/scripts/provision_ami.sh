#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "Update/Install Apt packages"
apt-get update
apt-get install -y supervisor
apt-get clean && rm -rf /var/lib/apt/lists/*

echo "Setup API"
mv /tmp/app /usr/local/bin/app
chmod +x /usr/local/bin/app

echo "Setup Supervisord"
mv /tmp/supervisord_app.conf /etc/supervisor/conf.d/app.conf
supervisorctl reread
supervisorctl update

echo "Check API health"
supervisorctl status
SERVER_STATUS=`curl -s http://localhost/health | grep -i ok && echo "up" || echo "down"`

if [ "${SERVER_STATUS}" = "down" ]; then
    echo "Fatal: Unable to start API server via Supervisord"
    exit 1
else
    echo "Success: API is Runnning"
fi