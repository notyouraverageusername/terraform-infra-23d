# Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "project-x-dev-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
