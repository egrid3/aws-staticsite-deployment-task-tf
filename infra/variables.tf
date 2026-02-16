variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "stack_name" {
  description = "Base name for resources (bucket name gets a unique suffix)."
  type        = string
}

variable "index_document" {
  description = "Index document for S3 static website hosting."
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for S3 static website hosting."
  type        = string
  default     = "404.html"
}

variable "github_repo_full_name" {
  description = "GitHub repo in owner/name format used for OIDC trust policy."
  type        = string
}

variable "tf_state_bucket_name" {
  description = "S3 bucket name used for Terraform remote state."
  type        = string
}

variable "tf_lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking."
  type        = string
}
