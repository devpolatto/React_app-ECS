terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }


  backend "s3" {
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region  = local.region
  profile = local.profile
}

