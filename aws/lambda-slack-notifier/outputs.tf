output "lambda-arn" {
  value = "${aws_lambda_function.main.arn}"
}

output "sns-arn" {
  value = "${aws_sns_topic.main.arn}"
}
