
terraform {
  backend "s3" {
    bucket       = "meridian-amdari-tf-state-bucket"
    key          = "global/s3/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
