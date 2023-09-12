variable "create" {
  default = true
  type    = bool
}

variable "enabled" {
  default = true
  type    = bool
}

variable "is_ipv6_enabled" {
  default = false
  type    = bool
}

variable "comment" {
  default = "terraform cloudfront"
  type    = string
}

variable "default_root_object" {
  default = "index.html"
  type    = string
}

variable "price_class" {
  default = "PriceClass_200"
  type    = string
}

variable "aliases" {
  default = []
  type    = list(string)
}

variable "allowed_methods" {
  default = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  type    = list(string)
}

variable "cached_methods" {
  default = ["GET", "HEAD"]
  type    = list(string)
}

variable "viewer_protocol_policy" {
  default = "allow-all"
  type    = string
}

variable "min_ttl" {
  default = 0
  type    = number
}

variable "default_ttl" {
  default = 3600
  type    = number
}

variable "max_ttl" {
  default = 86400
  type    = number
}

#### Cloudfront Blocks
variable "origins" {
  default = {}
}

variable "logging_config" {
  default = {}
}

variable "forwarded_values" {
  default = {}
}

variable "cache_behavior" {
  default = {}
}
#### Origin access idendity

variable "oac_name" {
  default = ""
  type    = string
}

variable "description" {
  default = "origin access control"
  type    = string
}

variable "oac_origin_type" {
  default = "s3"
  type    = string
}

variable "signing_behavior" {
  default = "always"
  type    = string
}

variable "signing_protocol" {
  default = "sigv4"
  type    = string
}
