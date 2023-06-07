resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "certifiles"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "N"
  }
  vpc_configuration {
    subnet_ids         = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
    security_group_ids = [aws_security_group.dynamodb_security_group.id]
  }
}
