#!/bin/bash

set -e

BIND_ADDR=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

sudo tee /etc/nomad.d/configuration.hcl > /dev/null <<EOF
bind_addr = "$BIND_ADDR"

data_dir = "/var/lib/nomad/data"

client {
  enabled = ${client}
}

server {
  bootstrap_expect = ${bootstrap_expect}
  enabled          = ${server}
}
EOF

sudo service nomad restart
