resource "aws_identitystore_group" "ReadOnly" {
  display_name      = "ReadOnly@${local.account_id}"
  description       = "ReadOnly"
  identity_store_id = local.identity_store_id
}

resource "aws_ssoadmin_permission_set" "ReadOnly" {
  name             = "ReadOnly"
  description      = "ReadOnlyAccess"
  instance_arn     = local.instance_arn
  relay_state      = var.default_aws_region != "" ? "https://console.aws.amazon.com/console/home?region=${var.default_aws_region}" : "https://console.aws.amazon.com/console/home"
  session_duration = "PT${var.default_session_duration}"
}

resource "aws_ssoadmin_managed_policy_attachment" "ReadOnly" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.ReadOnly.arn
}

resource "aws_ssoadmin_account_assignment" "ReadOnly" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.ReadOnly.arn

  principal_type = "GROUP"
  principal_id   = split("/", aws_identitystore_group.ReadOnly.id)[1]

  target_id   = local.account_id
  target_type = "AWS_ACCOUNT"
}

data "aws_identitystore_user" "ReadOnly" {
  for_each          = { for user in var.readonly_users : user => user }
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

resource "aws_identitystore_group_membership" "ReadOnly" {
  for_each = data.aws_identitystore_user.ReadOnly

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.ReadOnly.group_id
  member_id         = each.value.user_id
}
