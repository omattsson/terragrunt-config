# terragrunt-config
An example on how to use Terragrunt in Azure

# Terragrunt Azure Configuration Guide

This repository contains a structured Terragrunt configuration for managing Azure infrastructure across multiple environments, regions, and deployment units.

In this example I use random resources to generate outputs so no azurerm is needed. This should be enough to test how Terragrunt can be used to handle configuration changes on different levels in the hierarchy.

The config to generate the backend config is commented out in root.hcl

## Repository Structure

```
.
├── _envcommon/            # Common configuration for deployment units
│   ├── unit1.hcl          # Common configuration for unit1
│   └── unit2.hcl          # Common configuration for unit2
├── common.variables.tf    # Shared variables across all environments
├── root.hcl               # Root-level configuration
├── dev/                   # Development environment
│   ├── subscription.hcl   # Dev subscription configuration
│   ├── euw/               # Europe West region
│   │   ├── site.hcl       # Region-specific configuration
│   │   ├── dev1/          # Stack 1
│   │   └── dev2/          # Stack 2
│   └── use/               # US East region
├── prod/                  # Production environment
    └── ...
```

## Prerequisites

1. Install [Terraform](https://www.terraform.io/downloads.html) (version 1.0.0+)
2. Install [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
3. Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and authenticate:

   ```bash
   az login
   ```

## Getting Started

### Initialize and Apply a Single Unit

```bash
# Navigate to a specific unit directory
cd dev/euw/dev1/unit1

# Initialize and apply
terragrunt init
terragrunt apply
```

### Apply Changes to All Units in a Stack

```bash
# Navigate to a stack directory
cd dev/euw/dev1

# Apply all units in this stack
terragrunt run-all apply
```

## Overriding Inputs in Terragrunt

Terragrunt allows overriding inputs at multiple levels in the configuration hierarchy. Here are several methods:

### 1. Command Line Overrides

The simplest way to override inputs is through the command line:

```bash
terragrunt apply -var="resource_group_name=my-custom-rg"
```

### 2. Hierarchical Configuration Overrides

The most powerful method leverages Terragrunt's hierarchical configuration:

#### a. Modify `terragrunt.hcl` in the Unit Directory

Add or modify the `inputs` block in a unit's `terragrunt.hcl`:

```hcl
# dev/euw/dev1/unit1/terragrunt.hcl
inputs = {
  resource_group_name = "custom-rg-unit1"
}
```

#### b. Use Terragrunt Functions for Dynamic Overrides

```hcl
# dev/euw/dev1/unit1/terragrunt.hcl
inputs = {
  resource_group_name = "rg-${get_env("USER", "default")}-${local.environment}"
  tags = merge(
    local.common_tags,
    {
      Owner = get_env("TF_VAR_OWNER", "Team")
    }
  )
}
```

### 3. Input Merging Behavior

Terragrunt merges inputs from different levels with the following precedence (highest to lowest):

1. Command line variables
2. Environment variables
3. Local `terragrunt.hcl` inputs
4. Parent directory inputs
5. Common/default inputs

## Examples

### Unit-Specific Overrides

```hcl
# dev/use/dev2/unit1/terragrunt.hcl
inputs = {
  resource_group_name = "morgoth"
}
```

### Envcommon Overrides

```hcl
# _envcommon/unit1.hcl
inputs = {
  resource_group_name = "celebrimbor"
}
```

## Best Practices

1. Keep overrides minimal and specific to each level
2. Use common variables for shared settings
3. Use descriptive variable names that indicate their scope
4. Document custom overrides in comments
5. Test overrides by running `terragrunt plan` before applying

For more information, refer to the [official Terragrunt documentation](https://terragrunt.gruntwork.io/).
