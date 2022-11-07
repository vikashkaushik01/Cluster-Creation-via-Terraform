variable "region" {
  default = "us-east-1"
  description = "This is the region where the resources will be deployed"
  type = string
}

variable "vpc-cidr" {
  default       = "10.14.0.0/16"
  description   = "VPC CIDR Block"
  type          = string
}

variable "public-subnet-1-cidr" {
  default       = "10.14.1.0/24"
  description   = "Public Subnet 1 CIDR Block"
  type          = string
}

variable "public-subnet-2-cidr" {
  default       = "10.14.2.0/24"
  description   = "Public Subnet 2 CIDR Block"
  type          = string
}

variable "private-subnet-1-cidr" {
  default       = "10.14.3.0/24"
  description   = "Private Subnet 1 CIDR Block"
  type          = string
}

variable "private-subnet-2-cidr" {
  default       = "10.14.4.0/24"
  description   = "Private Subnet 2 CIDR Block"
  type          = string
}

variable "token" {
  default = "your nirmata profile token"
}
