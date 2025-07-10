# Set variables that are shared across the subscription
locals {
  subscription_id = "your-subscription-id"
  tenant_id      = "your-tenant-id"
  deployment_storage_resource_group_name = "your-deployment-storage-rg"
  deployment_storage_account_name        = "yourdeploymentstorageaccount"
  environment = "prod"
}