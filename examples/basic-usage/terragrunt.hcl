terraform {
  source = "git::git@github.com:AlainODea/terraform-aws-sso-named-sessions.git//modules/aws-sso-named-sessions?ref=main"
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