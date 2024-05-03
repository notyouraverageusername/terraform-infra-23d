locals {
  version = "1.29"
}
data "aws_ssm_parameter" "eks_ami_id" {
  name = "/aws/service/eks/optimized-ami/${local.version}/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "eks_workers" {
  name_prefix   = "project-x-eks-dev-worker-nodes"
  image_id      = data.aws_ssm_parameter.eks_ami_id.value
  instance_type = "t3.medium"

    # #!/bin/bash
    # set -o xtrace
    # /etc/eks/bootstrap.sh project-x-dev

# iam::aws:policy/AmazonEKSWorkerNodePolicy"
# iam::aws:policy/AmazonEKS_CNI_Policy"
# iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

resource "aws_autoscaling_group" "eks_workers" {
  capacity_rebalance  = true
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = ["subnet-071c8c8c1dd4c5732", "subnet-0e51b86773f6f6aa4"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks_workers.id
      }

      override {
        instance_type     = "t3.medium"
        weighted_capacity = "2"
      }

      override {
        instance_type     = "t2.medium"
        weighted_capacity = "2"
      }
    }
  }
}

# resource "aws_iam_role" "example" {
#   name = "eks-node-group-example"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.example.name
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.example.name
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.example.name
# }