terraform {
  backend "s3" {
    bucket         = "gcp-firenet"
    key            = "gcp-firenet.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock"
    profile        = "avxacc"
  }
}
