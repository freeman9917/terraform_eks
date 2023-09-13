provider "aws" {
  region     = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "my-brainscale-prod-bucket"
    key = "tr-state/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "my-brainscale-prod-dynamodb_table"    
}  
}


################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "my-${var.env_prefix}-vpc"
  cidr = var.cidr_block

  azs      = [var.az1, var.az2]
  public_subnets      = [var.pub1_subnet, var.pub2_subnet]
  private_subnets = [var.priv1_subnet, var.priv2_subnet]

  create_igw = true
  map_public_ip_on_launch = true
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  public_subnet_tags = {    
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${var.env_prefix}" = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.env_prefix}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  } 
}




################################################################################
# ECR Module
################################################################################
module "ecr" {
  source  = "./modules/ecr"
  ecr_name = "my-${var.env_prefix}-name"

}



################################################################################
# EKS Module
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = "${var.env_prefix}"
  cluster_endpoint_public_access = true
  node_security_group_tags = {
    "kubernetes.io/cluster/${var.env_prefix}" = null
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    ascode-cluster-wg = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "helloworld"
      }
    }
  }

}


################################################################################
# Helm Module
################################################################################
module "helm" {
  source = "./modules/helm"
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  cluster_name = module.eks.cluster_name
  kubernetes_namespace = module.kubernetes.kubernetes_namespace
}



################################################################################
#Kubernetes  Module
################################################################################
module "kubernetes" {
  source = "./modules/kubernetes"
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  cluster_name = module.eks.cluster_name
}



