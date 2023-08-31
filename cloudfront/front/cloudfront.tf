locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  count = var.create ? 1:0

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = local.s3_origin_id
    origin_path             = "/site"
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "Some comment"
  default_root_object = "index.html"

  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "myprefix"
  # }

  aliases = ["site3.cloudcraftman.net"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  # ordered_cache_behavior {
  #   path_pattern     = "/content/immutable/*"
  #   allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #   cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #   target_origin_id = local.s3_origin_id
  #
  #   forwarded_values {
  #     query_string = false
  #     headers      = ["Origin"]
  #
  #     cookies {
  #       forward = "none"
  #     }
  #   }
  #
  #   min_ttl                = 0
  #   default_ttl            = 86400
  #   max_ttl                = 31536000
  #   compress               = true
  #   viewer_protocol_policy = "redirect-to-https"
  # }

  # # Cache behavior with precedence 1
  # # ordered_cache_behavior {
  # #   path_pattern     = "/content/*"
  # #   allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  # #   cached_methods   = ["GET", "HEAD"]
  # #   target_origin_id = local.s3_origin_id
  # #
  # #   forwarded_values {
  # #     query_string = false
  # #
  # #     cookies {
  # #       forward = "none"
  # #     }
  # #   }
  # #
  # #   min_ttl                = 0
  # #   default_ttl            = 3600
  # #   max_ttl                = 86400
  # #   compress               = true
  # #   viewer_protocol_policy = "redirect-to-https"
  # # }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "production"
  }

 viewer_certificate {         
    acm_certificate_arn            = "arn:aws:acm:us-east-1:306192109948:certificate/c9b05d6d-8f13-470d-abdb-70610019c020"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  } 

}

resource "aws_cloudfront_origin_access_control" "this" {
  count = var.create ? 1:0

  name                              = "tf-aws-labs"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
