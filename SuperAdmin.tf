resource "aws_identitystore_group" "SuperAdmin" {
  display_name      = "SuperAdmin@${local.account_id}"
  description       = "SuperAdmin"
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

resource "aws_ssoadmin_permission_set" "SuperAdmin" {
  name             = "SuperAdmin"
  description      = "AdministratorAccess"
  instance_arn     = local.instance_arn
  relay_state      = var.default_aws_region != "" ? "https://console.aws.amazon.com/console/home?region=${var.default_aws_region}" : "https://console.aws.amazon.com/console/home"
  session_duration = "PT${var.default_session_duration}"
}

resource "aws_ssoadmin_managed_policy_attachment" "SuperAdmin" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.SuperAdmin.arn
}

resource "aws_ssoadmin_account_assignment" "SuperAdmin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.SuperAdmin.arn

  principal_type = "GROUP"
  principal_id   = split("/", aws_identitystore_group.SuperAdmin.id)[1]

  target_id   = local.account_id
  target_type = "AWS_ACCOUNT"
}

data "aws_identitystore_user" "SuperAdmin" {
  for_each          = { for user in var.super_admins : user => user }
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

resource "aws_identitystore_group_membership" "SuperAdmin" {
  for_each = data.aws_identitystore_user.SuperAdmin

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.SuperAdmin.group_id
  member_id         = each.value.user_id
}
