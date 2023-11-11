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

variable "app_subnet_prefix" {
    description = "Prefix of app subnets"
    type = string
    default = "app_subnet_"
}

variable "app_subnets" {
    description = "CIDRs of app subnets"
    type = list
    default = ["10.0.51.0/24", "10.0.52.0/24"]
}

variable "db_subnet_prefix" {
    description = "Prefix of db subnets"
    type = string
    default = "db_subnet_"
}

variable "db_subnets" {
    description = "CIDRs of db subnets"
    type = list
    default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "nacl_rule_number_step" {
    description = "NACL rule number setp"
    type = number
    default = 100
}

variable "public_allowed_ports" {
    description = "TCP ports allowed in public subnets"
    type = list
    default = [
        {
            protocol = "tcp",
            port = 22
        },
        {
            protocol = "tcp",
            port = 80
        },
        {
            protocol = "tcp",
            port = 443
        }
    ]
}

variable "app_allowed_ports" {
    description = "TCP ports allowed in app subnets"
    type = list
    default = [
        {
            protocol = "tcp",
            port = 22
        },
        {
            protocol = "tcp",
            port = 80
        },
        {
            protocol = "tcp",
            port = 443
        }
    ]
}

variable "db_allowed_ports" {
    description = "TCP ports allowed in db subnets"
    type = list
    default = [
        {
            protocol = "tcp",
            port = 22
        },
        {
            protocol = "tcp",
            port = 3306
        },
        {
            protocol = "tcp",
            port = 1521
        },
        {
            protocol = "tcp",
            port = 1830
        },
        {
            protocol = "tcp",
            port = 5432
        },
        {
            protocol = "tcp",
            port = 1433
        },
        {
            protocol = "tcp",
            port = 1434
        },
    ]
}

