resource "aws_iam_user" "github_actions" {
  name = "github-actions"
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

resource "aws_iam_user_policy" "github_actions_policy" {
  name = "github-actions-policy"
  user = aws_iam_user.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
          "eks:*",
          "ec2:Describe*",
          "eks:Describe*",
          "iam:PassRole",
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user" "aws_admin" {
  name = "aws-admin"
}

resource "aws_iam_access_key" "aws_admin" {
  user = aws_iam_user.aws_admin.name
}

resource "aws_iam_user_policy" "aws_admin_policy" {
  name = "aws-admin-policy"
  user = aws_iam_user.aws_admin.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}
