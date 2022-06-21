# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "role" {
  name = "${var.env}-${var.team}-role"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "policy" {
  name = "${var.env}-${var.team}-policy"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "role_policy" {
  policy_arn = aws_iam_policy.policy.arn
  role = aws_iam_role.role.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group
resource "aws_iam_group" "group" {
  name = "${var.env}-${var.team}-group"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment
resource "aws_iam_group_policy_attachment" "group_policy" {
  group = aws_iam_group.group.name
  policy_arn = aws_iam_policy.policy.arn
}

# A user, belonging to the above group

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user
resource "aws_iam_user" "user" {
  name = "${var.env}-${var.team}-user"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership
resource "aws_iam_user_group_membership" "user_group" {
  user = aws_iam_user.user.arn
  groups = [ aws_iam_group.group.name ]
}