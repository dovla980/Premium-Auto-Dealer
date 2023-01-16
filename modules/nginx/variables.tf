variable "public_subnet_cidrs" {
 type        = list(string) 
 default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
 
variable "private_subnet_cidrs" { 
 default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "avail_zones" {
  type = list(string)
  default = ["eu-west-3a","eu-west-3b"]
}

variable "instance_type" {
  type = string  
}

variable "aws_region" {
  type = string      
}

variable "tags" {
  type = map(string)  
}

variable "application_name" {
  type = string
  
}

