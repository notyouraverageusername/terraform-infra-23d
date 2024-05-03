resource "aws_eks_cluster" "cluster" {
  name     = "project-x-dev"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids = ["subnet-071c8c8c1dd4c5732", "subnet-0e51b86773f6f6aa4"]
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = "10.7.0.0/16"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role-AmazonEKSClusterPolicy
  ]

  tags = {
    Name = "project-x"
  }
}

# trust policy for the role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# create IAM role
resource "aws_iam_role" "eks_cluster_role" {
  name               = "project-x-dev-eks-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# attach policy to the role
resource "aws_iam_role_policy_attachment" "eks_cluster_role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


resource "aws_security_group" "eks_cluster_sg" {
  name        = "EKS Cluster Security Group"
  description = "Allow All inbound traffic from Self and all outbound traffic"
  vpc_id      = "vpc-02d676e7ae58fbc8e"

  tags = {
    Name = "eks-cluster-sg"
    "kubernetes.io/cluster/project-x-dev" = "owned"
    "aws:eks:cluster-name"	= "project-x-dev"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  referenced_security_group_id         = aws_security_group.eks_cluster_sg.id
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 
output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}
