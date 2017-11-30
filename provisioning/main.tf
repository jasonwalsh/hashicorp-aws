provider "aws" {
  region = "${var.region}"
}

module "default-client" {
  source = "./default"

  bootstrap_expect = "${var.default_clients}"
  name             = "client"
}

module "default-server" {
  source = "./default"

  bootstrap_expect = "${var.default_servers}"
  name             = "server"
}
