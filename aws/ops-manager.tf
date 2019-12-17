resource "aws_key_pair" "ops-manager" {
  key_name   = "${var.environment_name}-ops-manager-key"
  public_key = tls_private_key.ops-manager.public_key_openssh
}

resource "tls_private_key" "ops-manager" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_iam_access_key" "ops-manager" {
  user = aws_iam_user.ops-manager.name
}

resource "aws_iam_user" "ops-manager" {
  force_destroy = true
  name          = "${var.environment_name}-ops-manager"
}

resource "aws_iam_user_policy" "ops-manager" {
  name = "${var.environment_name}-ops-manager-policy"
  user = aws_iam_user.ops-manager.name

  policy = data.template_file.ops-manager.rendered
}

data "template_file" "ops-manager" {
  template = file("ops-manager-iam-policy.json")

  vars = {
    environment_name = var.environment_name
  }
}

resource "aws_eip" "ops-manager" {
  vpc = true
}
