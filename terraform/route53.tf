# Use the existing hosted zone
data "aws_route53_zone" "epooz_hosted_zone" {
  name         = "epooz.com"
  private_zone = false
}
#  terraform state rm aws_route53_zone.epooz_hosted_zone
# # Create a new hosted zone if it doesn't exist
# resource "aws_route53_zone" "epooz_hosted_zone" {
#   name = "epooz.com"
  
#   tags = {
#     Environment = "Development"
#     Project     = "serpent-surge"
#   }
# }

resource "aws_route53_record" "game_instance" {
  count   = 2

  zone_id = data.aws_route53_zone.epooz_hosted_zone.zone_id
  name    = "ec2-${count.index + 1}.epooz.com"
  type    = "A"

  alias {
    name                   = aws_lb.serpent_alb.dns_name
    zone_id                = aws_lb.serpent_alb.zone_id
    evaluate_target_health = true
  }
}

# Create ACM certificate
resource "aws_acm_certificate" "epooz_certificate" {
  domain_name               = "epooz.com"
  subject_alternative_names = ["*.epooz.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = "Development"
    Project     = "serpent-surge"
  }
}

# Create DNS records for certificate validation
resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.epooz_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.epooz_hosted_zone.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "epooz_certificate_validation" {
  certificate_arn         = aws_acm_certificate.epooz_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}

# Create DNS records for ALB
resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.epooz_hosted_zone.zone_id
  name    = "epooz.com"  # Root domain
  type    = "A"

  alias {
    name                   = aws_lb.serpent_alb.dns_name
    zone_id                = aws_lb.serpent_alb.zone_id
    evaluate_target_health = true
  }
}

# # Create DNS record for wildcard subdomain
# resource "aws_route53_record" "wildcard_record" {
#   zone_id = data.aws_route53_zone.epooz_hosted_zone.zone_id
#   name    = "*.epooz.com"  # Wildcard for all subdomains
#   type    = "A"

#   alias {
#     name                   = aws_lb.serpent_alb.dns_name
#     zone_id                = aws_lb.serpent_alb.zone_id
#     evaluate_target_health = true
#   }
# }

# Add www subdomain record
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.epooz_hosted_zone.zone_id
  name    = "www.epooz.com"
  type    = "A"

  alias {
    name                   = aws_lb.serpent_alb.dns_name
    zone_id                = aws_lb.serpent_alb.zone_id
    evaluate_target_health = true
  }
}