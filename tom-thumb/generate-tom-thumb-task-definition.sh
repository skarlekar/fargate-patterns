#!/bin/bash

: ${TASK_ROLE_ARN? "Need to set environment variable TASK_ROLE_ARN"}

if [ $# -ne 2 ]
then
    echo "Usage: $0 <videoFileUrl> <position-in-secs>"
    exit 1
fi

DIRECTORY=temp
if [ ! -d "$DIRECTORY" ]; then
  echo Creating temp directory
  mkdir temp
fi

export TIMESTAMP=`date +%Y%m%d_%H%M%S`
export INPUT_VIDEO_FILE_URL=$1
export OUTPUT_THUMBS_FILE_NAME=thumbnail_$TIMESTAMP.png
export POSITION_TIME_DURATION=00:$2
export ECR_IMAGE_LATEST=$ECR_REPO_URI:latest
export AWS_REGION=us-east-1
#export INPUT_VIDEO_FILE_URL=https://s3.amazonaws.com/skarlekar-ffmpeg/raw/samplevideo.mp4
#export OUTPUT_THUMBS_FILE_NAME=whats-up-bunny.png
export OUTPUT_S3_PATH=skarlekar-ffmpeg/thumbnail
cat register-tom-thumb-task-def-template.json | jq '.containerDefinitions[0].image = env.ECR_IMAGE_LATEST' | jq '.executionRoleArn = env.TASK_ROLE_ARN'| jq '.taskRoleArn = env.TASK_ROLE_ARN' | jq '.containerDefinitions[0].environment[0].value = env.AWS_REGION' | jq '.containerDefinitions[0].environment[1].value = env.INPUT_VIDEO_FILE_URL' | jq '.containerDefinitions[0].environment[2].value = env.OUTPUT_S3_PATH' | jq '.containerDefinitions[0].environment[3].value = env.OUTPUT_THUMBS_FILE_NAME' | jq '.containerDefinitions[0].environment[4].value = env.POSITION_TIME_DURATION'> temp/register-tom-thumb-task-definition.json
