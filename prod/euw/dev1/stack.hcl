# Here we set up the local variables for the all units in the stack
locals {
  site_vars         = read_terragrunt_config(find_in_parent_folders("site.hcl"))
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))
  stack             = basename(get_terragrunt_dir())
  realm             = local.stack
  default_tags = {
    stack      = local.stack
    location  = local.site_vars.locals.location
  }
}