output "upper_names" {
  value = [for name in var.user_names : upper(name)]
  description = "Names of created users"
}