terraform {
  backend "s3" {
    bucket = "dev-devops1"
    region = "us-east-1"
    key = "jenkins-server/terraform.tfstate"
  }
}