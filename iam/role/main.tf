locals {
  managed_policy = flatten([ for name,obj in var.create_role : 
                   [ for pol_arn in toset(obj.managed_policy) : {
                    key = "${name}-${replace(pol_arn, ":", "_")}"
                    role = name
                    policy_arn = pol_arn
                   }] ])

  permission_policy_list = flatten([ for name,obj in var.create_role : 
                   [ for indx, pol_arn in obj.permission_policy : {
                    key = "${name}-${indx}"
                    role = name
                    policy_arn = pol_arn
                   }] ])

  permission_policy = { for obj in local.permission_policy_list : obj.key => obj}   //keys must be fully known at plan time cuz list of policy_arns assigned dynamically
}

data "aws_iam_policy_document" "trust" {
  for_each = var.create_role

  statement {
    sid = "AssumeRole"
    effect = "Allow"

  principals {
    type = each.value.trust.type
    identifiers = each.value.trust.identifiers
  }

  actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  for_each = var.create_role

  name = each.key
  assume_role_policy = data.aws_iam_policy_document.trust[each.key].json
  description = "Role for ${each.key}"

  tags = merge(var.tags, 
  {
    Name = "Role-${each.key}"
  })
}

resource "aws_iam_role_policy_attachment" "role_managed_policy_attachment" {
 for_each = { for obj in local.managed_policy : obj.key => obj}
  
  role = aws_iam_role.role[each.value.role].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy_attachment" "role_permission_policy_attachment" {
  for_each = local.permission_policy

  role = aws_iam_role.role[each.value.role].name
  policy_arn = each.value.policy_arn
}