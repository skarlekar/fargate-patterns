#!/bin/bash

: ${TASK_ROLE_ARN? "Need to set environment variable TASK_ROLE_ARN"}
: ${SUBNET1? "Need to set environment variable SUBNET1"}
: ${SUBNET2? "Need to set environment variable SUBNET2"}
: ${SECURITYGROUP? "Need to set environment variable SECURITYGROUP"}

if [ $# -ne 3 ]
then
    echo "Usage: $0 <videoFileUrl> <position-in-secs> <bucket-for-writing-thumbnail>"
    exit 1
fi


export TIMESTAMP=`date +%Y%m%d_%H%M%S`
export ECR_IMAGE_LATEST=$ECR_REPO_URI:latest
export AWS_REGION=us-east-1
export INPUT_VIDEO_FILE_URL=$1
export OUTPUT_S3=$3
export OUTPUT_S3_PATH=$OUTPUT_S3/thumbnail
export OUTPUT_THUMBS_FILE_NAME=thumbnail_$TIMESTAMP.png
export POSITION_TIME_DURATION=00:$2
cat run-tom-thumb-task-template.json| \
	jq '.overrides.containerOverrides[0].environment[0].value = env.AWS_REGION' | \
	jq '.overrides.containerOverrides[0].environment[1].value = env.INPUT_VIDEO_FILE_URL' | \
	jq '.overrides.containerOverrides[0].environment[2].value = env.OUTPUT_S3_PATH' | \
	jq '.overrides.containerOverrides[0].environment[3].value = env.OUTPUT_THUMBS_FILE_NAME' | \
	jq '.overrides.containerOverrides[0].environment[4].value = env.POSITION_TIME_DURATION' | \
	jq '.overrides.taskRoleArn = env.TASK_ROLE_ARN' | \
	jq '.overrides.executionRoleArn = env.TASK_ROLE_ARN' | \
	jq '.networkConfiguration.awsvpcConfiguration.subnets = [env.SUBNET1, env.SUBNET2]' | \
	jq '.networkConfiguration.awsvpcConfiguration.securityGroups = [env.SECURITYGROUP]'  > temp/run-tom-thumb-task.json
