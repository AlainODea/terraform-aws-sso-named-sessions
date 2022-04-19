# terraform-aws-sso-named-sessions
Clearly named AWS SSO profile sessions to make it obvious what account you are in

It names the permission sets as {account}-{role} to make it obvious where you
are and as what role.

## Usage

This module assumes you have manually set up your SSO instance and Groups or
are provisioning groups externally with something like SCIM.

If you create or provision groups named aws-dev-admin, aws-prod-admin, and
aws-global-billing, then deploying the example below will yield four permission sets:

1. dev-admin
2. dev-billing
3. prod-admin
4. prod-billing

terragrunt.hcl:
```hcl
terraform {
  source = "git::git@github.com:AlainODea/terraform-aws-sso-named-sessions.git//modules/aws-sso-named-sessions?ref=master"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders()
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  sso_configuration = {
    "dev" = {
      account_id = "1111222233334444"
      assignments = {
        admin = {
          groups = [
            "aws-dev-admin",
          ]
          managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
        }
        billing = {
          groups = [
            "aws-global-billing",
          ]
          managed_policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
        }
      }
    }
    "prod" = {
      account_id = "1111222233334444"
      assignments = {
        admin = {
          groups = [
            "aws-prod-admin",
          ]
          managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
        }
        billing = {
          groups = [
            "aws-global-billing",
          ]
          managed_policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
        }
      }
    }
  }
}
```