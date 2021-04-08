terraform {
  backend "s3" {
    bucket = "terraform-remote-backend-bluegreen"
    key    = "remote-blue-green.tfstate"
    region = "eu-west-2"
  }
}