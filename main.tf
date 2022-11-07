#Create VPC
resource "aws_vpc" "testVPC" {
    cidr_block = var.vpc-cidr
    instance_tenancy        = "default"
    enable_dns_hostnames    = true
    enable_dns_support = true
    tags = {
      "Name" = "Test-VPC"
    }
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id    = aws_vpc.testVPC.id

  tags      = {
    Name    = "Test-IGW"
  }
}

#Create Public Subnet 1
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.testVPC.id
  cidr_block              = var.public-subnet-1-cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "Public-Subnet-1"
  }
}

#Create Public Subnet 2
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.testVPC.id
  cidr_block              = var.public-subnet-2-cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "Public-Subnet-2"
  }
}

#Create Public Route Table
resource "aws_route_table" "public-route-table" {
  vpc_id       = aws_vpc.testVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags       = {
    Name     = "Public-Route-Table"
  }
}

#Create Association with Public Route table and public subnet 1
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id           = aws_subnet.public-subnet-1.id
  route_table_id      = aws_route_table.public-route-table.id
}

#Create Association with Public Route table and public subnet 2
resource "aws_route_table_association" "public-subnet-2-route-table-association" {
  subnet_id           = aws_subnet.public-subnet-2.id
  route_table_id      = aws_route_table.public-route-table.id
}

# Create Private Subnet 1
resource "aws_subnet" "private-subnet-1" {
  vpc_id                   = aws_vpc.testVPC.id
  cidr_block               = var.private-subnet-1-cidr
  availability_zone        = "us-east-1a"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "Private-Subnet-1"
  }
}

# Create Private Subnet 2
resource "aws_subnet" "private-subnet-2" {
  vpc_id                   = aws_vpc.testVPC.id
  cidr_block               = var.private-subnet-2-cidr
  availability_zone        = "us-east-1b"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "Private-Subnet-2"
  }
}

# Create EIP for NAT Gateway
resource "aws_eip" "eip-for-nat-gateway" {
  vpc    = true
  tags   = {
    Name = "EIP-for-Test-NAT-Gateway"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eip-for-nat-gateway.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags   = {
    Name = "Test-Nat-Gateway"
  }
}

# Create Private Route Table
resource "aws_route_table" "private-route-table" {
  vpc_id            = aws_vpc.testVPC.id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat-gateway.id
  }

  tags   = {
    Name = "Private Route Table"
  }
}

#Create Association with Private Route Table and private subnet 1
resource "aws_route_table_association" "private-subnet-1-route-table-association" {
  subnet_id = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}

#Create Association with Private Route Table and private subnet 2
resource "aws_route_table_association" "private-subnet-2-route-table-association" {
  subnet_id = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}

# NACL Allow all
resource "aws_network_acl" "name" {
  vpc_id = aws_vpc.testVPC.id
  ingress {
    protocol = "-1"
    cidr_block = "0.0.0.0/0"
    rule_no = 100
    from_port = 0
    to_port = 0
    action = "allow"
  }
  egress {
    protocol = "-1"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
}

# ELB Traffic SG
resource "aws_security_group" "traffic-elb" {
  name = "allow http and https traffic from elb"
  description = "security group to allow http and https traffic from ELB"
  vpc_id = aws_vpc.testVPC.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "http traffic"
    from_port = 80
    ipv6_cidr_blocks = ["::/0"]
    protocol = "tcp"
    to_port = 80
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "https traffic ip"
    from_port = 443
    ipv6_cidr_blocks = ["::/0"]
    protocol = "tcp"
    to_port = 443
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "All Traffic"
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags = {
    "Name" = "allow-http-https-elb"
  }
}

#VPN security group
resource "aws_security_group" "VPN-sg" {
  name = "VPN-sg"
  description = "security group for VPN"
  vpc_id = aws_vpc.testVPC.id
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "http traffic"
    from_port = 80
    ipv6_cidr_blocks = [ "::/0" ]
    protocol = "tcp"
    to_port = 80
  }
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "https traffic"
    from_port = 443
    ipv6_cidr_blocks = [ "::/0" ]
    protocol = "tcp"
    to_port = 443
  }
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "VPN port"
    from_port = 11954
    protocol = "udp"
    to_port = 11954
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "All Traffic"
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags = {
    "Name" = "VPN-sg"
  }
}

#EKS CLuster and roles needed

resource "aws_iam_role" "eks-iam-role" {
  name = "eks-aim-role"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "lambda.amazonaws.com",
                    "eks.amazonaws.com",
                    "ec2.amazonaws.com",
                    "resources.cloudformation.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}

EOF

}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks-iam-role.id
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.eks-iam-role.id
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    role = aws_iam_role.eks-iam-role.id
  
}

resource "aws_eks_cluster" "test-cluster" {
  name = "test-cluster"
  role_arn = aws_iam_role.eks-iam-role.arn
  vpc_config {
    subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
  }
  depends_on = [
    aws_iam_role.eks-iam-role,
  ]
}
 
#EKS add-ons
resource "aws_eks_addon" "vpc-cni" {
    addon_name = "vpc-cni"
    cluster_name = aws_eks_cluster.test-cluster.id
    
}

resource "aws_eks_addon" "coredns" {
    addon_name = "coredns"
    cluster_name = aws_eks_cluster.test-cluster.id    
  
}

resource "aws_eks_addon" "kube-proxy" {
  addon_name = "kube-proxy"
  cluster_name = aws_eks_cluster.test-cluster.id
}

resource "aws_iam_role" "workernode-role" {
  name = "workernode-role"
  assume_role_policy = jsonencode({
        "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.workernode-role.id
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.workernode-role.id
}


resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.workernode-role.id
}


resource "aws_eks_node_group" "test-cluster-ng" {
  cluster_name = aws_eks_cluster.test-cluster.name
  node_group_name = "test-cluster-ng"
  node_role_arn = aws_iam_role.workernode-role.arn
  subnet_ids = [aws_subnet.private-subnet-1.id,aws_subnet.private-subnet-2.id]
  instance_types = ["t3a.medium"]
  disk_size = 50
  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]
}

resource "nirmata_cluster_registered" "eks-registered" {
  name         = "test-cluster"
  cluster_type = "default-add-ons"
    depends_on = [
    aws_vpc.testVPC,
    aws_internet_gateway.internet-gateway,
    aws_subnet.public-subnet-1,
    aws_subnet.public-subnet-2,
    aws_route_table.public-route-table,
    aws_route_table_association.public-subnet-1-route-table-association,
    aws_route_table_association.public-subnet-2-route-table-association,
    aws_subnet.private-subnet-1,
    aws_subnet.private-subnet-2,
    aws_eip.eip-for-nat-gateway,
    aws_nat_gateway.nat-gateway,
    aws_route_table.private-route-table,
    aws_route_table_association.private-subnet-1-route-table-association,
    aws_route_table_association.private-subnet-2-route-table-association,
    aws_network_acl.name,
    aws_iam_role.eks-iam-role,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_eks_addon.vpc-cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube-proxy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role.workernode-role,
    aws_eks_cluster.test-cluster,
    aws_eks_node_group.test-cluster-ng
  ]
}

# Retrieve eks cluster information
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.test-cluster.name
  depends_on = [
    aws_vpc.testVPC,
    aws_internet_gateway.internet-gateway,
    aws_subnet.public-subnet-1,
    aws_subnet.public-subnet-2,
    aws_route_table.public-route-table,
    aws_route_table_association.public-subnet-1-route-table-association,
    aws_route_table_association.public-subnet-2-route-table-association,
    aws_subnet.private-subnet-1,
    aws_subnet.private-subnet-2,
    aws_eip.eip-for-nat-gateway,
    aws_nat_gateway.nat-gateway,
    aws_route_table.private-route-table,
    aws_route_table_association.private-subnet-1-route-table-association,
    aws_route_table_association.private-subnet-2-route-table-association,
    aws_network_acl.name,
    aws_iam_role.eks-iam-role,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_eks_addon.vpc-cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube-proxy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role.workernode-role,
    aws_eks_cluster.test-cluster,
    aws_eks_node_group.test-cluster-ng
  ]
}


provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}

data "kubectl_filename_list" "manifests" {
  pattern = "${nirmata_cluster_registered.eks-registered.controller_yamls_folder}/*"
}

// apply the controller YAMLs
resource "kubectl_manifest" "test" {
  count     = nirmata_cluster_registered.eks-registered.controller_yamls_count
  yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))
  depends_on = [
    aws_vpc.testVPC,
    aws_internet_gateway.internet-gateway,
    aws_subnet.public-subnet-1,
    aws_subnet.public-subnet-2,
    aws_route_table.public-route-table,
    aws_route_table_association.public-subnet-1-route-table-association,
    aws_route_table_association.public-subnet-2-route-table-association,
    aws_subnet.private-subnet-1,
    aws_subnet.private-subnet-2,
    aws_eip.eip-for-nat-gateway,
    aws_nat_gateway.nat-gateway,
    aws_route_table.private-route-table,
    aws_route_table_association.private-subnet-1-route-table-association,
    aws_route_table_association.private-subnet-2-route-table-association,
    aws_network_acl.name,
    aws_iam_role.eks-iam-role,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_eks_addon.vpc-cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube-proxy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role.workernode-role,
    aws_eks_cluster.test-cluster,
    aws_eks_node_group.test-cluster-ng
  ]
}

resource "nirmata_environment" "tf-env-1" {
  name        = "test"
  type        = "medium"
  cluster     = "test-cluster"
  namespace   = "test"
  environment_update_action   = "notify" 
  depends_on = [
    nirmata_cluster_registered.eks-registered,
    kubectl_manifest.test
  ]
}

resource "nirmata_run_application" "tf-catalog-run-app" {
  name                = "tf-run-app"
  application         = "sumit-nginx"
  catalog             = "sumit-test"
  channel             = "Rapid"
  environments        = ["test"]
  depends_on = [
    aws_vpc.testVPC,
    aws_internet_gateway.internet-gateway,
    aws_subnet.public-subnet-1,
    aws_subnet.public-subnet-2,
    aws_route_table.public-route-table,
    aws_route_table_association.public-subnet-1-route-table-association,
    aws_route_table_association.public-subnet-2-route-table-association,
    aws_subnet.private-subnet-1,
    aws_subnet.private-subnet-2,
    aws_eip.eip-for-nat-gateway,
    aws_nat_gateway.nat-gateway,
    aws_route_table.private-route-table,
    aws_route_table_association.private-subnet-1-route-table-association,
    aws_route_table_association.private-subnet-2-route-table-association,
    aws_network_acl.name,
    aws_iam_role.eks-iam-role,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_eks_addon.vpc-cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube-proxy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role.workernode-role,
    aws_eks_cluster.test-cluster,
    aws_eks_node_group.test-cluster-ng,
    nirmata_cluster_registered.eks-registered,
    kubectl_manifest.test,
    nirmata_environment.tf-env-1
  ]
 }




