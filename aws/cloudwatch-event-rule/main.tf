resource "aws_cloudwatch_event_rule" "main" {
  count = length(var.aws_cloudwatch_event_rule)

  name          = var.aws_cloudwatch_event_rule[count.index].name
  description   = var.aws_cloudwatch_event_rule[count.index].description
  event_pattern = var.aws_cloudwatch_event_rule[count.index].event_pattern
}

resource "aws_cloudwatch_event_target" "main" {
  count = length(var.aws_cloudwatch_event_target)

  rule      = element(aws_cloudwatch_event_rule.main.*.name, count.index)
  target_id = element(var.aws_cloudwatch_event_target, count.index).target_id
  arn       = element(var.aws_cloudwatch_event_target, count.index).arn
}
