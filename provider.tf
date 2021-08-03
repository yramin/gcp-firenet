terraform {
  required_providers {

    aviatrix = {
      source = "AviatrixSystems/aviatrix"

    }
    aws = {
      region  = "us-east-1"
      profile = "avxacc"
      version = "3.42.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "3.76.0"
    }
  }
}
provider "aviatrix" {
  controller_ip = "52.71.215.202"
  username      = "admin"
  password      = ""
  version       = ">= 2.19.5"
}

provider "aws" {
  region  = var.aws_region_1
  profile = "avxacc"
  alias   = "region_1"
}
provider "aws" {
  region  = var.aws_region_2
  profile = "avxacc"
  alias   = "region_2"
}
provider "google" {
  # Configuration options
  project = "rndc-01"
  region  = "us-east1"
}
