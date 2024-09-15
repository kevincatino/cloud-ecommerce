# resource "aws_cloudfront_origin_access_control" "access_to_bucket" {
#   name                              = "www-bucket-access"
#   description                       = "WWW bucket OAC"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }

# locals {
#   distributions = {
#     www = {
#       origin_domain_name = aws_s3_bucket.www.bucket_regional_domain_name
#       origin_id          = "S3-${aws_s3_bucket.www.id}"
#     },
#     root = {
#       origin_domain_name = aws_s3_bucket_website_configuration.root.website_endpoint
#       origin_id          = "S3-${aws_s3_bucket.root.id}"
#     }
#   }
# }

# resource "aws_cloudfront_distribution" "website" {
#   for_each = local.distributions
#   enabled  = true
#   // aliases             = [var.domain_name] No tenemos certificado
#   default_root_object = each.key == "www" ? "index.html" : null
  
#   logging_config {
#     bucket         = aws_s3_bucket.logs.bucket_domain_name
#     include_cookies = false
#     prefix         = "logs/"
#   }
  
#   origin {
#     domain_name = each.value.origin_domain_name

#     origin_access_control_id = each.key == "www" ? aws_cloudfront_origin_access_control.access_to_bucket.id : null
#     origin_id                = each.value.origin_id

#     dynamic "custom_origin_config" {
#       for_each = each.key == "www" ? [] : ["placeholder"]
#       content {
#         http_port              = "80"
#         https_port             = "443"
#         origin_protocol_policy = "https-only"
#         origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#       }
#     }
#   }

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = each.value.origin_id

#     forwarded_values {
#       headers      = []
#       query_string = true
#       cookies {
#         forward = "all"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["AR"]
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true // Utilizamos el certificado de cloudfront a pesar de que lo ideal seria generar o importar un certificado con ACM y habilitar un alias hacia nuestro dominio
#   }
# }
