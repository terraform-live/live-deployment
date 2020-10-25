variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "user_names" {
   description = "User names in the environment"
   type         = list(string)
   default      = ["neo", "ugo", "emeka"]

}