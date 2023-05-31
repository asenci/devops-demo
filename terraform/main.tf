resource "aws_default_vpc" "this" {}

data "aws_region" "this" {}


data "aws_availability_zones" "this" {
  state = "available"
  filter {
    name   = "region-name"
    values = [data.aws_region.this.name]
  }
}

resource "aws_default_subnet" "this" {
  count = 3

  availability_zone = data.aws_availability_zones.this.names[count.index]
}


module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  repository_name = var.ecr-repository-name

  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection    = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

data "aws_ecr_authorization_token" "this" {}

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.this.proxy_endpoint
    username = data.aws_ecr_authorization_token.this.user_name
    password = data.aws_ecr_authorization_token.this.password
  }
}

resource "docker_image" "web" {
  name = "${module.ecr.repository_url}:latest"
  build {
    context  = "${path.root}/.."
    platform = "linux/amd64"
  }
  triggers = {
    src = sha256(join("", [for f in fileset(path.root, "../src/**"): filesha256(f)]))
  }
}

resource "docker_registry_image" "web" {
  name = docker_image.web.name
  triggers = {
    digest = docker_image.web.repo_digest
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name    = var.eks-cluster-name
  cluster_version = var.eks-cluster-version

  cluster_endpoint_public_access = true
  cluster_addons                 = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  subnet_ids = [for subnet in aws_default_subnet.this[*] : subnet.id]

  eks_managed_node_groups = {
    main = {
      desired_size   = var.eks-nodes-size-desired
      min_size       = var.eks-nodes-size-min
      max_size       = var.eks-nodes-size-max
      instance_types = var.eks-nodes-instance-types
    }
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.eks-app-namespace
  }
}

resource "kubernetes_deployment_v1" "web" {
  metadata {
    name      = var.eks-app-name
    namespace = var.eks-app-namespace
  }
  spec {
    replicas = var.eks-deployment-replicas

    selector {
      match_labels = {
        app = var.eks-app-name
      }
    }

    template {
      metadata {
        labels = {
          app = var.eks-app-name
          digest = sha1(docker_registry_image.web.sha256_digest)
        }
      }

      spec {
        container {
          name  = "web"
          image = docker_registry_image.web.name
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "web" {
  metadata {
    name      = var.eks-app-name
    namespace = var.eks-app-namespace
  }

  spec {
    type     = "LoadBalancer"
    selector = {
      app = var.eks-app-name
    }
    port {
      port = 80
    }
  }
}
