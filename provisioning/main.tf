provider "aws" {
  region = "${var.region}"
}

module "consul-client" {
  source = "./consul"

  bootstrap_expect = "${var.consul_clients}"
  name             = "client"
}

module "consul-server" {
  source = "./consul"

  bootstrap_expect = "${var.consul_servers}"
  name             = "server"
}
