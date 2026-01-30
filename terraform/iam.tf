# IAM role for GitHub Actions to access AWS
resource "aws_iam_user" "github_actions" {
  name = "${var.project_name}-github-actions"
  path = "/automation/"

  tags = merge(
    var.tags,
    {
      Name    = "${var.project_name}-github-actions"
      Purpose = "CI/CD automation"
    }
  )
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

# Policy for GitHub Actions
resource "aws_iam_user_policy" "github_actions" {
  name = "${var.project_name}-github-actions-policy"
  user = aws_iam_user.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = module.eks.cluster_arn
      }
    ]
  })
}

# Optional: IAM role for pods (IRSA - IAM Roles for Service Accounts)
# This allows Kubernetes pods to assume AWS IAM roles
resource "aws_iam_role" "pod_execution_role" {
  name = "${var.project_name}-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.cluster.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:inventory-system:backend"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-pod-execution-role"
    }
  )
}

# Attach policies if pods need AWS service access
# Example: S3, SES, etc.
resource "aws_iam_role_policy" "pod_execution_policy" {
  name = "${var.project_name}-pod-policy"
  role = aws_iam_role.pod_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}
