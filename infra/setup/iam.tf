#######################################
# Create IAM user and policies for CD #
#######################################

resource "aws_iam_user" "cd_bookyland" {
  name = "bookyland-app-cd"
}

resource "aws_iam_access_key" "cd_bookyland" {
  user = aws_iam_user.cd_bookyland.name
}

########################################################
# Policy for terraform backend to s3 and Dynamo access #
########################################################

data "aws_iam_policy_document" "tf_backend" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.tf_state_bucket}"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "S3:DeleteObject"]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket}/tf-state-deploy/*",
      "arn:aws:s3:::${var.tf_state_bucket}/tf-state-deploy-env/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    # Fisrt asterisc for account and second one for region
    resources = [
      "arn:aws:dynamo:*:*:table/${var.tf_state_lock_table}"
    ]
  }
}


resource "aws_iam_policy" "tf_backend" {
  name        = "${aws_iam_user.cd_bookyland.name}-tf-s3-dynamo"
  description = "Allow user to use s3 and dynamo as backend state and lock"
  policy      = data.aws_iam_policy_document.tf_backend.json
}

resource "aws_iam_user_policy_attachment" "tf_backend" {
  user       = aws_iam_user.cd_bookyland.name
  policy_arn = aws_iam_policy.tf_backend.arn
}


