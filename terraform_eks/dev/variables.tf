variable "env_prefix" {
    type = string
    default = "dev"
}

# variable "security_groups" {
#     type = string
#     default = ""
# }

variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "pub1_subnet" {
    type = string
    default = "10.0.101.0/24"
}

variable "pub2_subnet" {
    type = string
    default = "10.0.102.0/24"
}

variable "priv1_subnet" {
    type = string
    default = "10.0.1.0/24"
}

variable "priv2_subnet" {
    type = string
    default = "10.0.2.0/24"
}

variable "az1" {
    type = string
    default = "eu-central-1a"
}

variable "az2" {
    type = string
    default = "eu-central-1b"
}

