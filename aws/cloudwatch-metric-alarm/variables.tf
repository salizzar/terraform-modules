variable "aws_cloudwatch_metric_alarm" {
  type = object({
    tags = map(string)

    alarms = list(object({
      alarm_name          = string
      comparison_operator = string
      evaluation_periods  = number
      metric_name         = string
      namespace           = string
      period              = number
      statistic           = string
      threshold           = number
      treat_missing_data  = string
      datapoints_to_alarm = number
      alarm_actions       = list(string)
      ok_actions          = list(string)
      dimensions          = map(string)
    }))
  })
}
