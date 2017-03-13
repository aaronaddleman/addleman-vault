# Configure the AWS Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "vault-bucket" {
  bucket = "${var.aws_account_id}-vault"
  acl = "private"

  tags {
    Name = "Vault bucket"
    Environment = "Dev"
    Service = "Vault"
  }
}

data "aws_iam_policy_document" "vault-bucket-policy-data" {
  statement {
    sid = "VaultPermissions"
    actions = [
      "s3:*"
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::615197564783:user/tf"]
    }
    resources = [
      "arn:aws:s3:::${var.aws_account_id}-vault"
    ]
  }
}

resource "aws_s3_bucket_policy" "vault-policy" {
  bucket = "${aws_s3_bucket.vault-bucket.id}"
  policy = "${data.aws_iam_policy_document.vault-bucket-policy-data.json}"
}

data "aws_iam_policy_document" "vault-role-policy-data" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::615197564783:root"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "vault-role" {
  name = "vault-ec2"
  assume_role_policy = "${data.aws_iam_policy_document.vault-role-policy-data.json}"
}

# User
resource "aws_iam_user" "vault-init" {
  name = "vault-init"
}

resource "aws_iam_user_policy_attachment" "vault-init-policy-attach" {
  user = "${aws_iam_user.vault-init.name}"
  policy_arn = "${aws_iam_policy.vault-init-policy.arn}"
}

resource "aws_iam_policy" "vault-init-policy" {
  name = "vault-init-policy"
  description = "Vault Init Policy"
  policy = "${data.aws_iam_policy_document.vault-init-policy-data.json}"
}

data "aws_iam_policy_document" "vault-init-policy-data" {
  statement {
    sid = "VaultInitPermissions"
    actions = [
      "s3:*"
    ]
    resources = [
      "*"
    ]
  }
}


# instance

resource "aws_instance" "vault" {
  ami = "ami-0b33d91d"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.vault-sg.id}"]
  #userdata = "${file("userdata.sh")}"
  tags {
    Service = "vault"
    Environment = "dev"
  }
}

resource "aws_security_group" "vault-sg" {
  name = "vault-sg"
  vpc_id = "${var.vpc}"

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/24"]
    from_port = 8200
    to_port = 8200
  }

  ingress {
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0"]
    from_port = 8200
    to_port = 8200
  }

  ingress {
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0"]
    from_port = 22
    to_port = 22
  }

  tags {
    Name = "main"
  }
}
