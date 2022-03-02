data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "eks-sandbox-vpc"
  cidr   = "10.9.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.9.1.0/24", "10.9.2.0/24"]
  public_subnets  = ["10.9.11.0/24", "10.9.12.0/24"]

  enable_nat_gateway = true

  tags = merge(
    local.default_tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      "karpenter.sh/discovery" = var.cluster_name
    }
  )
}

module "eks_cluster" {
  source             = "../../modules/eks"
  vpc_id             = module.vpc.vpc_id
  cluster_name       = var.cluster_name
  cluster_version    = "1.21"
  subnet_ids         = module.vpc.private_subnets
  private_subnet_ids = module.vpc.private_subnets

  tags = merge(
    local.default_tags,
    {
      "karpenter.sh/discovery" = var.cluster_name
    }
  )
}

data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
  role       = module.eks_cluster.worker_iam_role_name
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = module.eks_cluster.worker_iam_role_name
}

module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "karpenter-controller-${var.cluster_name}"
  provider_url                  = module.eks_cluster.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]
}

resource "aws_iam_role_policy" "karpenter_controller" {
  name = "karpenter-policy-${var.cluster_name}"
  role = module.iam_assumable_role_karpenter.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "iam:PassRole",
          "ec2:TerminateInstances",
          "ec2:DescribeLaunchTemplates",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}