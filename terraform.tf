# Option 2: S3 Remote State (Production)
terraform {
  backend "s3" {
    bucket         = "projects381"
    key            = "myshop/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile    = true
    encrypt        = true
  }
}