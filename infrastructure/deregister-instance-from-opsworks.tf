//There is a known bug that results in an opworks instance not properly deregistering upon Terraform Destroy.
//Manually deregistering that instance will allow Terraform Destroy to be run successfully

data "archive_file" "deregister-ec2-from-opsworks" {
  type        = "zip"
  source_file = "./templates/lambda/deregister-ec2-from-opsworks.py"
  output_path = "./templates/lambda/deregister-ec2-from-opsworks.zip"
}

resource "aws_lambda_function" "deregister-ec2-from-opsworks" {
  function_name = "deregister-ec2-from-opsworks"

  filename         = "${data.archive_file.deregister-ec2-from-opsworks.output_path}"
  source_code_hash = "${data.archive_file.deregister-ec2-from-opsworks.output_base64sha256}"
  role             = "${aws_iam_role.execution-role-for-lambda.arn}"
  description      = "deregister ec2 from opsworks"
  handler          = "deregister-ec2-from-opsworks.lambda_handler"
  runtime          = "python3.6"

}

resource "aws_sns_topic_subscription" "deregister-ec2-from-opsworks" {
  topic_arn = "${aws_sns_topic.autoscale-notification-topic.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.deregister-ec2-from-opsworks.arn}"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.deregister-ec2-from-opsworks.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.autoscale-notification-topic.arn}"
}
