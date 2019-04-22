#!/bin/bash

: ${S3_BUCKET_NAME? "Need to set environment variable S3_BUCKET_NAME. This is the bucket which will notify the lambda when a video file is put"}

aws s3api put-bucket-notification-configuration \
	--bucket $S3_BUCKET_NAME \
	--notification-configuration file://s3-notification.json
