variable "ecr-repository-name" {
  default = "devops-demo"
}

variable "eks-cluster-name" {
  default = "devops-demo"
}

variable "eks-cluster-version" {
  default = "1.27"
}

variable "eks-app-name" {
  default = "devops-demo"
}

variable "eks-app-namespace" {
  default = "devops-demo"
}

variable "eks-deployment-replicas" {
  type = number
  default = 1
}

variable "eks-nodes-size-desired" {
  type = number
  default = 1
}

variable "eks-nodes-size-min" {
  type = number
  default = 1
}

variable "eks-nodes-size-max" {
  type    = number
  default = 4
}

variable "eks-nodes-instance-types" {
  type = list(string)
  default = ["t3.large"]
}
