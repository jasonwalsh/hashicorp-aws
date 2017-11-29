#!/bin/bash

set -e

BIND_ADDR=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "bind_addr": "$BIND_ADDR",
  "bootstrap_expect": ${bootstrap_expect},
  "client_addr": "0.0.0.0",
  "data_dir": "/opt/consul/data",
  "leave_on_terminate": true,
  "retry_join": ${retry_join},
  "server": ${server},
  "skip_leave_on_interrupt": true,
  "ui": true
}
EOF

sudo service consul restart
