#!/bin/bash

set -e

sudo tee /etc/vault.d/configuration.hcl > /dev/null <<EOF
disable_mlock = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

storage "consul" {
  address = "127.0.0.1:8500"
  scheme  = "http"
}
EOF

sudo service vault restart
