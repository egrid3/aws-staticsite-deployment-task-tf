#!/usr/bin/env bash
set -euo pipefail

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is required on PATH" >&2
  exit 1
fi

if [ ! -d "infra" ]; then
  echo "infra/ not found. Run from repo root." >&2
  exit 1
fi

read_output() {
  local name="$1"
  terraform -chdir=infra output -raw "$name" 2>/dev/null || true
}

site_bucket_name="$(read_output site_bucket_name)"
github_actions_role_arn="$(read_output github_actions_role_arn)"
github_terraform_role_arn="$(read_output github_terraform_role_arn)"

site_bucket_value="${site_bucket_name:-<run terraform apply to populate>}"
actions_role_value="${github_actions_role_arn:-<run terraform apply to populate>}"
terraform_role_value="${github_terraform_role_arn:-<run terraform apply to populate>}"

cat <<EOF
GitHub Actions variables to set:

AWS_REGION=us-east-1
S3_BUCKET=${site_bucket_value}
AWS_ROLE_ARN=${actions_role_value}
AWS_TERRAFORM_ROLE_ARN=${terraform_role_value}
TF_STATE_BUCKET=<from bootstrap output>
TF_STATE_DDB_TABLE=<from bootstrap output>
TF_STATE_KEY=static-site/terraform.tfstate
STACK_NAME=<your stack_name>
REPO_FULL_NAME=<owner/repo>
EOF

if [ -z "$site_bucket_name" ] || [ -z "$github_actions_role_arn" ] || [ -z "$github_terraform_role_arn" ]; then
  echo "" >&2
  echo "Some outputs are missing. Ensure you've run 'terraform apply' in infra/." >&2
fi
