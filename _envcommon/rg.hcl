locals {
  stack_vars        = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  site_vars         = read_terragrunt_config(find_in_parent_folders("site.hcl"))
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))
  base_source_url   = "tfr://registry.terraform.io/claranet/rg/azurerm"
}
inputs = {
  client_name    = "claranet"
  location_short = local.site_vars.locals.location
}