include "root" {
  path           = find_in_parent_folders("root.hcl")
  merge_strategy = "deep"
}
include "envcommon" {
  path = "${get_repo_root()}/_envcommon/rg.hcl"
  # We want to reference the variables from the included config in this configuration, so we expose it.
  expose         = true
  merge_strategy = "deep"
}
terraform {
  source = "${include.envcommon.locals.base_source_url}?version=8.0.0"
}
# Here we set up the inputs for the unit
inputs = {
  project_name        = "May the force be with you"
  resource_group_name = "glorfindel"
  name_suffix         = "glorfindel"
  tags = {
    Owner = "The EU Team"
  }
}