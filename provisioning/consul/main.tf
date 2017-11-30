data "aws_ami" "default" {
  filter {
    name   = "name"
    values = ["desolate-fjord"]
  }

  most_recent = true
  owners      = ["self"]
}

data "aws_iam_policy_document" "discover" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_instance_profile" "discover" {
  role = "${aws_iam_role.discover.name}"
}

resource "aws_iam_role" "discover" {
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_role_policy" "discover" {
  policy = "${data.aws_iam_policy_document.discover.json}"
  role   = "${aws_iam_role.discover.id}"
}

data "template_file" "consul" {
  template = "${file("${path.module}/templates/consul.tpl")}"

  vars {
    bootstrap_expect = "${var.name == "server" ? var.bootstrap_expect : 0}"
    retry_join       = "[\"provider=aws tag_key=Name tag_value=default-server\"]"
    server           = "${var.name == "server" ? true : false}"
  }

  count = "${var.bootstrap_expect}"
}

data "template_file" "nomad" {
  template = "${file("${path.module}/templates/nomad.tpl")}"

  vars {
    bootstrap_expect = "${var.name == "server" ? var.bootstrap_expect : 0}"
    client           = "${var.name == "client" ? true : false}"
    server           = "${var.name == "server" ? true : false}"
  }

  count = "${var.bootstrap_expect}"
}

data "template_cloudinit_config" "default" {
  base64_encode = true
  gzip          = true

  part {
    content = "${element(data.template_file.consul.*.rendered, count.index)}"
  }

  part {
    content = "${element(data.template_file.nomad.*.rendered, count.index)}"
  }

  count = "${var.bootstrap_expect}"
}

resource "aws_security_group" "default" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = -1
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = -1
    to_port     = 0
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "default" {
  ami                  = "${data.aws_ami.default.id}"
  iam_instance_profile = "${aws_iam_instance_profile.discover.name}"
  instance_type        = "t2.small"
  key_name             = "default"
  security_groups      = ["${aws_security_group.default.name}"]

  tags = {
    Name = "default-${var.name}"
  }

  user_data = "${element(data.template_cloudinit_config.default.*.rendered, count.index)}"

  count = "${var.bootstrap_expect}"
}
