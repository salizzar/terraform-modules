locals {
  additional_tags = {
    Environment = terraform.workspace
  }
}

module "iam-user" {
  source = "../iam-system-user"

  aws_iam_user = {
    name = var.aws_iam_user.name
    path = var.aws_iam_user.path
    tags = merge(var.aws_iam_user.tags, local.additional_tags)
  }

  aws_iam_access_key = {
    pgp_key = var.aws_iam_access_key.pgp_key
  }

  aws_iam_role = {
    name = var.aws_iam_role.name

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
}
EOF

    tags = merge(var.aws_iam_user.tags, local.additional_tags)
  }

  aws_iam_role_policy = {
    name = var.aws_iam_role_policy.name

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TraefikDefaultPermissions",
            "Effect": "Allow",
            "Action": [
                "ecs:DescribeClusters",
                "ecs:DescribeTasks",
                "ecs:DescribeContainerInstances",
                "ecs:DescribeTaskDefinition",
                "ecs:ListClusters",
                "ecs:ListTasks",
                "ec2:DescribeInstances",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ssm:GetParameters"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "TraefikCrossAccount",
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:DescribeImages",
                "ecr:DescribeRepositories",
                "ecr:GetAuthorizationToken",
                "ecr:GetDownloadUrlForLayer",
                "ecr:ListImages"
            ],
            "Resource": "*"
        }
    ]
}
EOF
  }

  aws_iam_user_policy = {
    name = var.aws_iam_user_policy.name
  }
}
