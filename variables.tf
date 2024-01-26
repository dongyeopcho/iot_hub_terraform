locals {
  NowTime = timestamp()
}

locals {
  common_tags = {
    Environment = "dev"
    Owner = "Derik"
    ManagedBy = "Terraform"
    DeploymentTimestamp = timeadd(timestamp(), "9h")
  }
}

variable "com_var" {
}

variable "subscription_id" {
  description = "Azure subscription ID"
}