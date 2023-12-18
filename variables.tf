variable "env" {
  type = string
  default = "dev"
  description = "Environment"
}

locals {
  common_tags = {
    Environment = var.env
    Owner = ""
    ManagedBy = "Terraform"
    DeploymentTimestamp = timeadd(timestamp(), "9h")
  }
}