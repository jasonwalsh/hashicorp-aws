provider "aws" {
  region = "${var.region}"
}

module "default-client" {
  source = "./consul"

  bootstrap_expect = "${var.default_clients}"
  name             = "client"
}

module "default-server" {
  source = "./consul"

  bootstrap_expect = "${var.default_servers}"
  name             = "server"
}
