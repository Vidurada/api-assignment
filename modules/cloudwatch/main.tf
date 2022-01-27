resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "yousician-api-dev-dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApiGateway", "Latency", "ApiName", "yousician-dev-api", { "label": "Primary (us-west-2)" } ],
                    [ "...", { "region": "us-east-1", "label": "Secondary (us-east-1)" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "title": "API Latency",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApiGateway", "Count", "ApiName", "yousician-dev-api", { "label": "Primary (us-west-2)" } ],
                    [ "...", { "region": "us-east-1", "label": "Secondary (us-east-1)" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "period": 300,
                "stat": "Sum"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApiGateway", "4XXError", "ApiName", "yousician-dev-api", { "stat": "Sum", "label": "4XXError Primary (us-west-2)" } ],
                    [ ".", "5XXError", ".", ".", { "label": "5XXError Average Primary (us-west-2)" } ],
                    [ ".", "4XXError", ".", ".", { "stat": "Sum", "region": "us-east-1", "label": "4XXError Secondary (us-east-1)" } ],
                    [ ".", "5XXError", ".", ".", { "region": "us-east-1", "label": "5XXError Average Secondary (us-east-1)" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", "yousician-dev-table", { "label": "ConsumedReadCapacityUnits Primary (us-west-2)" } ],
                    [ ".", "ConsumedWriteCapacityUnits", ".", ".", { "label": "ConsumedWriteCapacityUnits Primary (us-west-2)" } ],
                    [ ".", "ConsumedReadCapacityUnits", ".", ".", { "region": "us-east-1", "label": "ConsumedReadCapacityUnits Secondary (us-east-1)" } ],
                    [ ".", "ConsumedWriteCapacityUnits", ".", ".", { "region": "us-east-1", "label": "ConsumedWriteCapacityUnits Secondary (us-east-1)" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "title": "Dynamodb RW Capacity",
                "period": 300,
                "stat": "Average"
            }
        }
    ]
}
EOF
}









