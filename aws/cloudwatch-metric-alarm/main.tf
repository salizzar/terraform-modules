locals {
  additional_tags = {
    Environment = terraform.workspace
  }
}

resource "aws_cloudwatch_metric_alarm" "alarms" {
  count = length(var.aws_cloudwatch_metric_alarm.alarms)

  tags = merge(
    var.aws_cloudwatch_metric_alarm.tags,
  local.additional_tags)

  alarm_name          = var.aws_cloudwatch_metric_alarm.alarms[count.index].alarm_name
  comparison_operator = var.aws_cloudwatch_metric_alarm.alarms[count.index].comparison_operator
  evaluation_periods  = var.aws_cloudwatch_metric_alarm.alarms[count.index].evaluation_periods
  metric_name         = var.aws_cloudwatch_metric_alarm.alarms[count.index].metric_name
  namespace           = var.aws_cloudwatch_metric_alarm.alarms[count.index].namespace
  period              = var.aws_cloudwatch_metric_alarm.alarms[count.index].period
  statistic           = var.aws_cloudwatch_metric_alarm.alarms[count.index].statistic
  threshold           = var.aws_cloudwatch_metric_alarm.alarms[count.index].threshold
  datapoints_to_alarm = var.aws_cloudwatch_metric_alarm.alarms[count.index].datapoints_to_alarm
  treat_missing_data  = lookup(element(var.aws_cloudwatch_metric_alarm.alarms, count.index), "treat_missing_data", "missing")
  dimensions          = var.aws_cloudwatch_metric_alarm.alarms[count.index].dimensions
  alarm_actions       = var.aws_cloudwatch_metric_alarm.alarms[count.index].alarm_actions
  ok_actions          = var.aws_cloudwatch_metric_alarm.alarms[count.index].ok_actions
}
