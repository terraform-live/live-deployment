output "upper_names" {
  value = [for name in var.user_names : upper(name)]
  description = "Names of created users"
}

output "user_names" {
  value = values(aws_iam_user.example)[*].name
  description = "Names of created users"
}

#output "user_name" {
#  value = aws_iam_user.example[*].name
#  description = "Names of created users"
#}
