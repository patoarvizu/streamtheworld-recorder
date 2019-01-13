[
    {
        "name": "stwr",
        "image": "${stwr_repository}:${stwr_version}",
        "command": [
            "/streamtheworld/streamtheworld.sh",
            "--call-signal",
            "D99",
            "--time-length",
            "300",
            "--recording-name",
            "stwr-test",
            "--copy-to-s3"
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${cloudwatch_logs_group}",
                "awslogs-region": "us-east-1",
                "awslogs-stream-prefix": "ecs"
            }
        }
    }
]