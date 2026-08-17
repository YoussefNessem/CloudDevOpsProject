terraform {
  backend "s3" {
    bucket       = "ivolve-backend-bucket"
    key          = "terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
    encrypt      = true
  }
}