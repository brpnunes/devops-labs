variable "region" {
    description = "AWS Region"
    type = string
    default = "us-east-1"
}

variable "cidr" {
    description = "CIDR of the VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "tag_env" {
    description = "Environment tag"
    type = string
    default = "dev"
}

variable "public_subnet_prefix" {
    description = "Prefix of public subnet names"
    type = string
    default = "public_subnet_"
}

variable "public_subnets" {
    description = "CIDRs of public subnets"
    type = list
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_prefix" {
    description = "Prefix of private subnet names"
    type = string
    default = "private_subnet_"
}

variable "private_subnets" {
    description = "CIDRs of private subnets"
    type = list
    default = ["10.0.51.0/24", "10.0.52.0/24"]
}