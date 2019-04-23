#!/bin/bash

: ${TASK_ROLE_ARN? "Need to set environment variable TASK_ROLE_ARN"}

DIRECTORY=temp
if [ ! -d "$DIRECTORY" ]; then
  echo Creating temp directory
  mkdir temp
fi

export ECR_IMAGE_LATEST=$ECR_REPO_URI:latest
cat register-bean-counter-task-def-template.json | jq '.containerDefinitions[0].image = env.ECR_IMAGE_LATEST' | jq '.executionRoleArn = env.TASK_ROLE_ARN'| jq '.taskRoleArn = env.TASK_ROLE_ARN' > temp/register-bean-counter-task-definition.json

