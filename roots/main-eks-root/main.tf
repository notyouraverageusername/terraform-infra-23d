module "project-x-eks-cluster" {
  source = "../../eks-module"
  name = var.name
  CIDR = var.CIDR
  instance_type = var.instance_type
  cluster_tag = var.cluster_tag
  vpc_id = var.vpc_id
  subnet_ids = var.subnet_ids
}
