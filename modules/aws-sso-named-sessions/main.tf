data "aws_ssoadmin_instances" "sso_instance" {}

locals {
  ssoadmin_instance_arn = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]

  ssoadmin_permission_sets_list = flatten([
    for account_name, account in var.sso_configuration : {
      for role_name, role in account.assignments : "${account_name}-${role_name}" => {
        managed_policy_arn = role.managed_policy_arn
      }
    }
  ])
  ssoadmin_permission_sets = merge(local.ssoadmin_permission_sets_list...)

  ssoadmin_account_assignments_list = flatten([
    for account_name, account in var.sso_configuration : flatten([
      for role_name, role in account.assignments : {
        for group_name in role.groups : "${account_name}-${role_name}-${group_name}" => {
          permission_set_key = "${account_name}-${role_name}"
          group_key          = group_name
          account_id         = account.account_id
        }
      }
    ])
  ])
  ssoadmin_account_assignments = merge(local.ssoadmin_account_assignments_list...)

  identitystore_groups_list = flatten([
    for account_name, account in var.sso_configuration : flatten([
      for role_name, role in account.assignments : {
        for group_name in role.groups : group_name => group_name
      }
    ])
  ])

  identitystore_groups = merge(local.identitystore_groups_list...)
}

resource "aws_ssoadmin_permission_set" "sets" {
  for_each = local.ssoadmin_permission_sets

  name         = each.key
  instance_arn = local.ssoadmin_instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "attachments" {
  for_each = local.ssoadmin_permission_sets

  instance_arn       = local.ssoadmin_instance_arn
  managed_policy_arn = each.value.managed_policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.sets[each.key].arn
}

resource "aws_ssoadmin_account_assignment" "assignments" {
  for_each           = local.ssoadmin_account_assignments
  instance_arn       = local.ssoadmin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.sets[each.value.permission_set_key].arn

  principal_id   = data.aws_identitystore_group.groups[each.value.group_key].group_id
  principal_type = "GROUP"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}

data "aws_identitystore_group" "groups" {
  for_each = local.identitystore_groups

  identity_store_id = tolist(data.aws_ssoadmin_instances.sso_instance.identity_store_ids)[0]

  filter {
    attribute_path  = "DisplayName"
    attribute_value = each.value
  }
}
