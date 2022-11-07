# Cluster-Creation-via-Terraform

## Pre-Requisite
AWS CLI should be Configure with AWS Credentials
You should have Nirmata Profile Token

### Created eks cluster with addons and networking resources:
VPC
IG
NAT
EIP
2 Public RT's and 2 Private RT's
NACL's
Security groups
EKS Cluster
Eks-role with policies attached
Node roles with policies attached
Cluster with following addons
Coredns
Kube-proxy
Vpc-cni
EKS managed node groups
main.tf

### EKS Cluster Registration with Nirmata
Nirmata Environment
Nginx Application
