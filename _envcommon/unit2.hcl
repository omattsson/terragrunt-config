locals {
  stack_vars        = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  site_vars         = read_terragrunt_config(find_in_parent_folders("site.hcl"))
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))
  base_source_url   = "git::https://github.com/omattsson/simple-tf-module"
}
inputs = {
  project_name = "Unit 2 Project"
}