provider "aws" {
  region = "us-west-2" # Specify your desired AWS region
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "static-website-hosting-1234" # Replace with a unique bucket name

  tags = {
    Name = "StaticWebsiteBucket"
  }
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website_bucket.bucket
  key    = "index.html"
  source = "c:/Users/choud/Desktop/almonds-email-v1/Template 1/index.html" # Replace with the path to your index.html file
  acl    = "private"
   content_type = "text/html" 
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.website_bucket.bucket
  key    = "error.html"
  source = "c:/Users/choud/Desktop/almonds-email-v1/Template 1/error.html" # Replace with the path to your error.html file
  acl    = "private"
  content_type = "text/html" 
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for static website bucket"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn,
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.website_bucket.arn}/*",
      },
    ],
  })
}

resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-Website"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Static website distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Website"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN"] # Restrict access to the United States
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "WebsiteDistribution"
  }
}
