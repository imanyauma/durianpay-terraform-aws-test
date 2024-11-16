# resource "aws_cloudwatch_dashboard" "durianpay_test_dashboard" {
#   dashboard_name = "DurianPayDashboard"
#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         "type"   : "metric",
#         "x"      : 0,
#         "y"      : 0,
#         "width"  : 12,
#         "height" : 6,
#         "properties": {
#           "metrics": [
#             [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name ]
#           ],
#           "title": "CPU Utilization",
#         }
#       },
#       {
#         "type"   : "metric",
#         "x"      : 12,
#         "y"      : 0,
#         "width"  : 12,
#         "height" : 6,
#         "properties": {
#           "metrics": [
#             [ "CWAgent", "mem_used_percent", "AutoScalingGroupName", var.autoscaling_group_name ]
#           ],
#           "title": "Memory Utilization"
#         }
#       }
#     ]
#   })
# }

resource "aws_cloudwatch_dashboard" "durianpay_test_dashboard" {
  dashboard_name = "DurianpayDashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Widget for CPU Utilization
      {
        "type"   : "metric",
        "x"      : 0,
        "y"      : 0,
        "width"  : 12,
        "height" : 6,
        "properties": {
          "metrics": [
            [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name ]
          ],
          "title": "CPU Utilization (%)",
          "stat": "Average",
          "period": 300,
          "region": "us-east-1"
        }
      },
      # Widget for Memory Utilization (requires CloudWatch Agent)
      {
        "type"   : "metric",
        "x"      : 12,
        "y"      : 0,
        "width"  : 12,
        "height" : 6,
        "properties": {
          "metrics": [
            [ "CWAgent", "mem_used_percent", "AutoScalingGroupName", var.autoscaling_group_name ]
          ],
          "title": "Memory Utilization (%)",
          "stat": "Average",
          "period": 300,
          "region": "us-east-1"
        }
      },
      # Widget for Status Check Failed
      {
        "type"   : "metric",
        "x"      : 0,
        "y"      : 6,
        "width"  : 12,
        "height" : 6,
        "properties": {
          "metrics": [
            [ "AWS/EC2", "StatusCheckFailed", "AutoScalingGroupName", var.autoscaling_group_name ],
            [ ".", "StatusCheckFailed_Instance", ".", "." ],
            [ ".", "StatusCheckFailed_System", ".", "." ]
          ],
          "title": "Instance Status Checks",
          "stat": "Sum",
          "period": 300,
          "region": "us-east-1"
        }
      },
      # Widget for Network In
      {
        "type"   : "metric",
        "x"      : 12,
        "y"      : 6,
        "width"  : 12,
        "height" : 6,
        "properties": {
          "metrics": [
            [ "AWS/EC2", "NetworkIn", "AutoScalingGroupName", var.autoscaling_group_name ]
          ],
          "title": "Network In (Bytes)",
          "stat": "Average",
          "period": 300,
          "region": "us-east-1"
        }
      },
      # Widget for Network Out
      {
        "type"   : "metric",
        "x"      : 0,
        "y"      : 12,
        "width"  : 12,
        "height" : 6,
        "properties": {
          "metrics": [
            [ "AWS/EC2", "NetworkOut", "AutoScalingGroupName", var.autoscaling_group_name ]
          ],
          "title": "Network Out (Bytes)",
          "stat": "Average",
          "period": 300,
          "region": "us-east-1"
        }
      }
    ]
  })
}