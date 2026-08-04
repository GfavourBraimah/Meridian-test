# oidc.tf

# Automatically fetch GitHub's latest TLS certificate live!
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# 1. Register GitHub as an Identity Provider using the dynamic thumbprint
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# 2. Create an IAM Role that GitHub Actions can assume securely
resource "aws_iam_role" "github_actions_oidc" {
  name = "MeridianGitHubActionsOIDCRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:GfavourBraimah/Meridian-test:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# 3. Grant the Role permissions to push to ECR
resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}