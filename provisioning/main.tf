provider "aws" {
  region = "${var.region}"
}

module "consul" {
  source = "./consul"

  bootstrap_expect = "${var.consul_bootstrap_expect}"
}
