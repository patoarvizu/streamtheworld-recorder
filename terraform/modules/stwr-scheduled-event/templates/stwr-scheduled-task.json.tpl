{
    "containerOverrides": [
        {
            "name": "stwr",
            "command": [
                "/streamtheworld/streamtheworld.sh",
                "--call-signal",
                "${call_signal}",
                "--time-length",
                "${time_length}",
                "--recording-name",
                "${recording_name}",
                "--copy-to-s3"
            ]
        }
    ]
}