# Cluster-Creation-via-Terraform

## Pre-Requisite
AWS CLI should be Configure with AWS Credentials
You should have Nirmata Profile Token

Note:- Currently this module is supported to:-

	1. OS:- CentOS, MacOS
	2. Terraform Version:- v1.3.6

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

Steps to Create the Cluster 

```
terraform init
```
```
terraform plan -target nirmata_cluster_registered.eks-registered
```
```
terraform apply -target nirmata_cluster_registered.eks-registered
```

Steps to Deploy Application 

```
terraform plan
```
```
terraform apply
```

Steps to Delete Application
```
terraform destroy  -target nirmata_cluster_registered.eks-registered
```


Steps to Delete Both Application and 
Cluster
```
terraform destroy
```


