output "staticsite_bucket_name" {
  description = "Name of the S3 bucket hosting the site."
  value       = aws_s3_bucket.staticsite.bucket
}

output "staticsite_bucket_website_endpoint" {
  description = "S3 website endpoint for the site."
  value       = aws_s3_bucket_website_configuration.staticsite.website_endpoint
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC."
  value       = aws_iam_role.github_actions.arn
}

output "github_terraform_role_arn" {
  description = "IAM role ARN for GitHub Actions Terraform workflow."
  value       = aws_iam_role.github_terraform.arn
}
