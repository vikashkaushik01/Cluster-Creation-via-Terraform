terraform {
  required_providers {
    nirmata = {
      source = "nirmata/nirmata"
      version = "1.1.7-rc8"
    }
    aws = {
        source  = "hashicorp/aws"
        version = ">= 3.20.0"
      }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

provider "nirmata" {
  # Nirmata address.
  url = "https://nirmata.io"
  // Nirmata API Key. Also configurable using the environment variable NIRMATA_TOKEN.
  token = var.token
}
