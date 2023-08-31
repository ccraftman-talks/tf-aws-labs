resource "aws_s3_bucket" "this" {
  bucket = "devco-tf-labs-3"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Terraform   = "true"
    Borrar      = "true"
  }
}

# output "s3_outputs" {
#   value = aws_s3_bucket.this
# }

# module "front" {
#   source = "./front/"
#
#   create = false
# }
