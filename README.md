# Nicolas Cage Fan Page (static)

This repository contains a small static fan page built with vanilla HTML, CSS, and JavaScript.

Pages included:

- `index.html` — Home / welcome
- `bio.html` — Short biography
- `about.html` — About this demo site
- `films.html` — Films & awards (renders `data/films.json` client-side)

How to run locally (using npx live-server):

This uses `npx` so you don't need to install a global package. Make sure you have Node.js and npm installed.

```bash
# from the repository root
# runs a simple static server with live reload on port 8080
npx live-server --port=8080
# then open http://localhost:8080/index.html in your browser
```

If you prefer a global install instead of `npx`, run:

```bash
# install globally (optional)
npm install -g live-server
live-server --port=8080
```

Notes:

- This is a demo/fan page for learning purposes. The site currently uses placeholder images (from picsum.photos) as visual examples.
- If you want photos of Nicolas Cage specifically, make sure to use properly licensed images — do not upload or publish copyrighted photos without permission. Replace image URLs in `data/films.json` and the `src` of the profile image in `bio.html` with your own licensed files (or host them in `assets/images/`).
- The films list is a small curated JSON sample in `data/films.json` and is used by `assets/js/main.js`.

To replace placeholders with local images:

1. Create `assets/images/` and add images (e.g., `leaving-las-vegas.jpg`).
2. Update `data/films.json` to point to `/assets/images/leaving-las-vegas.jpg` instead of the picsum URL.

## Deploying to AWS S3 (public bucket) with Terraform + GitHub Actions

This repo includes Terraform for AWS infrastructure and a GitHub Actions workflow for CI/CD. The setup is fully IaC (no clickops) and uses GitHub OIDC instead of long‑lived AWS keys.

Important notes before you begin:
- Bucket names must be globally unique. The Terraform module uses a unique suffix.
- S3 static website endpoints serve over HTTP. For HTTPS or a custom domain, use CloudFront in front of the bucket.
- A public bucket is intentionally less secure than private S3 + CloudFront. If you want that model later, we can switch.

### 1) Bootstrap Terraform state (recommended)

Terraform needs remote state for team-safe operations. Use the bootstrap Terraform in `infra/bootstrap/` to create the state bucket + lock table, then use `infra/backend.hcl` to point Terraform at it.

```bash
cd infra/bootstrap
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your unique state bucket name
terraform init
terraform apply

cd ..
cp backend.hcl.example backend.hcl
# edit backend.hcl with the bucket/table names from bootstrap outputs
```

### 2) Configure Terraform variables

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
# update infra/terraform.tfvars with:
# - stack_name
# - github_repo_full_name (owner/repo)
```

### 3) Provision infrastructure

```bash
cd infra
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

Terraform outputs the S3 bucket name, website endpoint, and GitHub Actions role ARNs (deploy + Terraform).

### 4) Configure GitHub Actions variables

Add these repository variables (Settings → Secrets and variables → Actions → Variables):
- `AWS_ROLE_ARN` = Terraform output `github_actions_role_arn`
- `S3_BUCKET` = Terraform output `site_bucket_name`
- `AWS_REGION` = `us-east-1`
- `AWS_TERRAFORM_ROLE_ARN` = Terraform output `github_terraform_role_arn`
- `TF_STATE_BUCKET` = Terraform state bucket name (from bootstrap output)
- `TF_STATE_KEY` = Terraform state key (e.g., `static-site/terraform.tfstate`)
- `TF_STATE_DDB_TABLE` = Terraform lock table name (from bootstrap output)
- `STACK_NAME` = the same `stack_name` value you use in Terraform
- `REPO_FULL_NAME` = `owner/repo` (same as Terraform variable)

After `terraform apply`, you can print the values with:

```bash
./scripts/print-github-vars.sh
```

### 5) Deploy

Push to `main` and GitHub Actions will sync the site to S3.

### Terraform CI/CD behavior

- Pull requests run `terraform fmt`, `validate`, and `plan`.
- Pushes to `main` run `terraform apply -auto-approve`.

Note: the very first `terraform apply` must be run with AWS credentials that can create IAM roles and the GitHub OIDC provider. After that, use the `github_terraform_role_arn` output in CI.

### Optional: CloudFront for HTTPS/custom domain

Add a CloudFront distribution in front of the S3 website endpoint and update DNS. (Not included in this Terraform yet.)
