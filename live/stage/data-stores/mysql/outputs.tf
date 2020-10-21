output "address" {
    value	= aws_db_instance.stage.address
    description = "Connect to the Database at this endpoint"
}

output "port" {
    value	= aws_db_instance.stage.port
    description = "The port the Database is listening on"
}
