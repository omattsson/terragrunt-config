include "root" {
  path           = find_in_parent_folders("root.hcl")
  merge_strategy = "deep"
}
include "envcommon" {
  path = "${get_repo_root()}/_envcommon/unit1.hcl"
  # We want to reference the variables from the included config in this configuration, so we expose it.
  expose         = true
  merge_strategy = "deep"
}
terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=main"
}
# Here we set up the inputs for the unit
inputs = {
  project_name = "All your base are belong to us"
}