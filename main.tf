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
}