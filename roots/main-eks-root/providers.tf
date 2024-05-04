# Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "githubactions-terrafrom-task"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
