terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

########## iam users ##############
#resource "aws_iam_user" "example" {
#  count = length(var.user_names)
#  name = var.user_names[count.index]
#}

resource "aws_iam_user" "example" {
    for_each = toset(var.user_names)
    name     = each.value
}
