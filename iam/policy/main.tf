data "aws_iam_policy_document" "policy" {
  for_each = var.create_policy

  statement {
    sid = each.value.sid
    effect = each.value.effect
    actions = each.value.actions
    resources = each.value.resources

    // Principals cannot be passed as {} -  AWS does not allowed it and if {} we should avoid rendering the pricipals
    dynamic "principals" {
      for_each = each.value.principal == null ? [] : [each.value.principal]
      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      }
    }
  }
}

resource "aws_iam_policy" "policy" {
  for_each = var.create_json ? {} : var.create_policy

  name = each.key
  policy = data.aws_iam_policy_document.policy[each.key].json
  description = "Policy for ${each.key}"

  tags = merge(var.tags, {
    Name = "Policy-${each.key}"
  })
}