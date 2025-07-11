variable "subscription_id" {
  description = "The Azure subscription ID to use for the deployment."
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID to use for the deployment."
  type        = string
}

variable "deployment_storage_resource_group_name" {
  description = "The name of the resource group where the deployment storage account is located."
  type        = string
}

variable "deployment_storage_account_name" {
  description = "The name of the storage account where the deployment files are located."
  type        = string
}
