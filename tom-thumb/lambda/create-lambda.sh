#!/bin/bash

: ${S3_BUCKET_ARN? "Need to set environment variable S3_BUCKET_ARN. This is the bucket which will notify the lambda when a video file is uploaded"}
: ${LAMBDA_ROLE_ARN? "Need to set environment variable LAMBDA_ROLE_ARN"}
: ${SUBNET1? "Need to set environment variable SUBNET1"}
: ${SUBNET2? "Need to set environment variable SUBNET2"}
: ${SECURITYGROUP? "Need to set environment variable SECURITYGROUP"}

export FUNCTION_NAME=task-runner

# Check if lambda exists
LAMBDA_ARN=$(aws lambda list-functions | jq '.Functions[] | select(.FunctionName == env.FUNCTION_NAME) | .FunctionArn' |  sed "s/\"//g")
if [ ! -z "$LAMBDA_ARN" ]; then
    echo LAMBDA: $FUNCTION_NAME exists as ARN: $LAMBDA_ARN. Attempting to update function...
    aws lambda update-function-code --function $FUNCTION_NAME \
        --zip-file fileb://lambda-function.zip
else
    echo LAMBDA $FUNCTION_NAME does not exist. Attempting to create function...
    aws lambda create-function --function-name $FUNCTION_NAME \
        --zip-file fileb://lambda-function.zip --handler lambda-function.lambda_handler --runtime python3.7 \
        --role $LAMBDA_ROLE_ARN --environment Variables="{SUBNET1=$SUBNET1,SUBNET2=$SUBNET2,SECURITYGROUP=$SECURITYGROUP}"

    aws lambda add-permission \
        --function-name $FUNCTION_NAME \
        --action lambda:InvokeFunction \
        --principal s3.amazonaws.com \
        --source-arn $S3_BUCKET_ARN \
        --statement-id 1
fi
