locals {
  s3_origin_id = "s3_origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  count = var.create ? 1 : 0

  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = var.comment
  default_root_object = var.default_root_object

  price_class = var.price_class
  aliases     = var.aliases

  dynamic "origin" {
    for_each = var.origins

    content {
      connection_attempts      = 3
      connection_timeout       = 10
      domain_name              = origin.value["domain_name"]
      origin_access_control_id = aws_cloudfront_origin_access_control.this[0].id
      origin_id                = local.s3_origin_id
      origin_path              = origin.value["origin_path"]
    }
  }

  dynamic "logging_config" {
    for_each = var.logging_config

    content {
      include_cookies = false
      bucket          = "mylogs.s3.amazonaws.com"
      prefix          = "myprefix"
    }
  }

  default_cache_behavior {
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = var.viewer_protocol_policy
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    min_ttl                = var.min_ttl

    dynamic "forwarded_values" {
      for_each = var.forwarded_values
      iterator = i

      content {
        query_string = i.value["query_string"]

        dynamic "cookies" {
          for_each = i.value["cookies"]

          content {
            forward = cookies.value
          }
        }
      }
    }
  }

  # Cache behavior with precedence 0
  dynamic "ordered_cache_behavior" {
    for_each = var.cache_behavior
    iterator = i

    content {
      path_pattern           = lookup(i.value["path_pattern"], ["/content/immutable/*"])
      allowed_methods        = lookup(i.value["allowed_methods"], ["GET", "HEAD", "OPTIONS"])
      cached_methods         = lookup(i.value["cached_methods"], ["GET", "HEAD", "OPTIONS"])
      min_ttl                = lookup(i.value["min_ttl"], 0)
      default_ttl            = lookup(i.value["default_ttl"], 86400)
      max_ttl                = lookup(i.value["max_ttl"], 31536000)
      compress               = lookup(i.value["compress"], true)
      viewer_protocol_policy = lookup(i.value["viewer_protocol_policy"], "redirect-to-https")

      target_origin_id = local.s3_origin_id

      dynamic "forwarded_values" {
        for_each = i.value["forwarded_values"]
        iterator = f

        content {
          query_string = lookup(f.value["query_string"], false)
          headers      = lookup(f.value["headers"], ["Origin"])

          dynamic "cookies" {
            for_each = i.value["cookies"]

            content {
              forward = lookup(cookies.value["forward"], "none")
            }
          }
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:306192109948:certificate/c9b05d6d-8f13-470d-abdb-70610019c020"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "this" {
  count = var.create ? 1 : 0

  name                              = var.oac_name
  description                       = var.description
  origin_access_control_origin_type = var.oac_origin_type
  signing_behavior                  = var.signing_behavior
  signing_protocol                  = var.signing_protocol
}

