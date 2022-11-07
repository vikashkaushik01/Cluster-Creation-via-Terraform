output "cluster_name" {
  value = aws_eks_cluster.test-cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.test-cluster.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.test-cluster.certificate_authority[0].data
}