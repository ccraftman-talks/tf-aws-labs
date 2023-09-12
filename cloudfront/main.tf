terraform {
  backend "s3" {
    encrypt = true
    bucket  = "devco-tf-labs"
    region  = "us-east-1"
    key     = "modules/front.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      env       = "dev"
      terraform = true
      borrar    = true
    }
  }
}


module "front" {
  source = "./front/"

  aliases = ["site3.cloudcraftman.net"]


  origins = {
    "s3" = {
      domain_name = aws_s3_bucket.this.bucket_regional_domain_name
      origin_path = "/site"
    }
  }

  forwarded_values = [
    {
      query_string = true
      cookies = {
        forward = "all"
      }
    }
  ]

  cache_behavior = {
    allowed_methods = ["GET", "HEAD"]
    forwarded_values = {
      query_string = true
      cookies = {
        forward = "all"
      }
    }
  }

  ### Origin Access Control
  oac_name = "tf-aws-labs"
}


resource "aws_s3_bucket" "this" {
  bucket = "devco-tf-labs-site"
}
