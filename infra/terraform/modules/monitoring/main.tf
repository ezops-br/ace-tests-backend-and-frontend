resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = var.alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 80
  dimensions = {
    ClusterName = "PLACEHOLDER_CLUSTER"
    ServiceName = "PLACEHOLDER_SERVICE"
  }
  alarm_description = "Alarm when ECS task CPU usage exceeds 80%"
  treat_missing_data = "breaching"
}
