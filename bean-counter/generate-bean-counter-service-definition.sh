#!/bin/bash

: ${SUBNET1? "Need to set environment variable SUBNET1"}
: ${SUBNET2? "Need to set environment variable SUBNET2"}
: ${SECURITYGROUP? "Need to set environment variable SECURITYGROUP"}
: ${TG_ARN? "Need to set environment variable TG_ARN"}

DIRECTORY=temp
if [ ! -d "$DIRECTORY" ]; then
  echo Creating temp directory
  mkdir temp
fi

cat create-bean-counter-service-def-template.json| jq '.loadBalancers[0].targetGroupArn = env.TG_ARN' | jq '.networkConfiguration.awsvpcConfiguration.subnets = [env.SUBNET1, env.SUBNET2]'| jq '.networkConfiguration.awsvpcConfiguration.securityGroups = [env.SECURITYGROUP]' > temp/create-bean-counter-service-definition.json

