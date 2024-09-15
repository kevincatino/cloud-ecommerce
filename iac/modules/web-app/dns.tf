# resource "aws_route53_zone" "primary" {
#   name = var.domain_name
# }

# resource "aws_route53_record" "www" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = var.domain_name
#   type    = "A"
#   alias {
#     name                   = aws_s3_bucket_website_configuration.www.website_domain
#     zone_id                = aws_s3_bucket.www.hosted_zone_id
#     evaluate_target_health = false
#   }
# }
