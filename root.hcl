locals {
  # Automatically load environment-level variables
  stack_vars = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  # Automatically load site-level variables
  site_vars = read_terragrunt_config(find_in_parent_folders("site.hcl"))
  # Automatically load environment-level variables
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))

  # Extract the variables we need for easy access in this file
  subscription_id                        = local.subscription_vars.locals.subscription_id
  deployment_storage_resource_group_name = local.subscription_vars.locals.deployment_storage_resource_group_name
  deployment_storage_account_name        = local.subscription_vars.locals.deployment_storage_account_name
  # tf_container_name is the name of the Blob Storage container where the Terraform state file will be stored
  tf_container_name = "tf-state"
}

# Generate an Azure provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {
  key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  storage_use_azuread = true
}
EOF
}
# Configure Terragrunt to automatically store tfstate files in an Blob Storage container. The storage account and
# contain must already exist.
# For this test we don't use a remote state.
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    subscription_id      = local.subscription_id
    resource_group_name  = local.deployment_storage_resource_group_name
    storage_account_name = local.deployment_storage_account_name
    container_name       = local.tf_container_name
    key                  = "${path_relative_to_include("site")}/terraform.tfstate"
  }
}
# Generate a common variables file that can be included in all child configurations
generate "common-variables" {
  path      = "common.variables.tf"
  if_exists = "overwrite"
  contents  = file("${get_repo_root()}/common.variables.tf")
}
terraform {
  # Force Terraform to keep trying to acquire a lock for
  # up to 20 minutes if someone else already has the lock
  extra_arguments "retry_lock" {
    commands = get_terraform_commands_that_need_locking()

    arguments = [
      "-lock-timeout=20m",
    ]
  }
  extra_arguments "parallelism" {
    commands = ["plan", "apply"]

    arguments = [
      "-parallelism=500"
    ]
  }
}
terraform_version_constraint = ">= 1.12.0"
# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.stack_vars.locals,
  local.site_vars.locals,
  local.subscription_vars.locals,
  {
    prefix = "${local.subscription_vars.locals.environment}-${local.site_vars.locals.site_name}-${local.stack_vars.locals.stack}"
  }
)
# ---------------------------------------------------------------------------------------------------------------------
# END GLOBAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------
