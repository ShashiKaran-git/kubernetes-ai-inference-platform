module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.33"

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
    
  subnet_ids = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_size = 1
      min_size     = 1
      max_size     = 2

      instance_types = ["t3.small"]
    }
  }

  tags = {
    Project = "AI-Inference"
  }
}