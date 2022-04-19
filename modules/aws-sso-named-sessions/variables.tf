variable "sso_configuration" {
  type = map(object({
    account_id = string
    assignments = map(object({
      groups             = list(string)
      managed_policy_arn = string
    }))
  }))

  default = {
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
