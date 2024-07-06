<powershell>
Start-Sleep -Seconds 30
$architecture = $env:PROCESSOR_ARCHITECTURE.ToLower()

$parameters = @{
	Uri = "https://s3.amazonaws.com/amazoncloudwatch-agent/windows/$architecture/latest/AmazonCloudWatchAgent.zip"
	OutFile = "$env:TEMP\AmazonCloudWatchAgent.zip"
}
Invoke-WebRequest @parameters

Expand-Archive -Path "$env:TEMP\AmazonCloudWatchAgent.zip" -DestinationPath "$env:TEMP\AmazonCloudWatchAgent"

Set-Location -Path "$env:TEMP\AmazonCloudWatchAgent"
.\install.ps1

$jsonContent = @'
{
    "logs": {
        "logs_collected": {
            "windows_events": {
                "collect_list": [
                    {
                        "event_format": "xml",
                        "event_levels": [
                            "VERBOSE",
                            "INFORMATION",
                            "WARNING",
                            "ERROR",
                            "CRITICAL"
                        ],
                        "event_name": "System",
                        "log_group_class": "STANDARD",
                        "log_group_name": "System",
                        "log_stream_name": "{instance_id}",
                        "retention_in_days": 90
                    }
                ]
            }
        }
    },
    "metrics": {
        "aggregation_dimensions": [
            [
            "InstanceId"
            ]
        ],
        "append_dimensions": {
            "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
            "ImageId": "${aws:ImageId}",
            "InstanceId": "${aws:InstanceId}",
            "InstanceType": "${aws:InstanceType}"
        },
        "metrics_collected": {
            "LogicalDisk": {
                "measurement": [
                        "% Free Space"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                        "*"
                ]
            },
            "Memory": {
                "measurement": [
                        "% Committed Bytes In Use"
                ],
                "metrics_collection_interval": 60
            },
            "statsd": {
                "metrics_aggregation_interval": 60,
                "metrics_collection_interval": 60,
                "service_address": ":8125"
            }
        }
    }
}
'@

$path = "C:\ProgramData\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent.json"
$jsonContent | Out-File -FilePath $path -Encoding Ascii -Force

Set-Location -Path 'C:\Program Files\Amazon\AmazonCloudWatchAgent\'
.\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c file:$path -s

</powershell>