terraform {
  backend "s3" {
    bucket = "s3-bucket-state"
    key = "global/s3/terraform.tfstate"
    region = "eu-west-3"
    encrypt = true
  }
}

module "nginx" {
  source = "./modules/nginx"  
  instance_type = "t3.micro"
  aws_region = "eu-west-3"
  tags = {
    "Provider" = "Terraform"
  }
  application_name = "nginx"
}