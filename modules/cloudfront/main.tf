resource "aws_cloudfront_distribution" "api_distribution" {
  origin_group {
    origin_id = "apifailover"

    failover_criteria {
      status_codes = [502, 503, 504]
    }

    member {
      origin_id = "primaryapi"
    }

    member {
      origin_id = "secondaryapi"
    }

  }

  origin {
    origin_id   = "primaryapi"
    domain_name = var.primary_api_stage_domain
    origin_path = var.primary_api_stage_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

  }

  origin {
    origin_id   = "secondaryapi"
    domain_name = var.secondary_api_stage_domain
    origin_path = var.secondary_api_stage_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

  }
  enabled = true
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET"]
    viewer_protocol_policy = "allow-all"
    target_origin_id       = "primaryapi"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.global_tags


}