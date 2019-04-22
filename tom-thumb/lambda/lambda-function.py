import json
import boto3
import os
import time
import random
def lambda_handler(event, context):
  client = boto3.client('ecs')
  subnet1=os.environ['SUBNET1']
  subnet2=os.environ['SUBNET2']
  securityGroup=os.environ['SECURITYGROUP']
  timestr = time.strftime("%Y%m%d-%H%M%S")
  randomNumber = random.randint(1,1001)

  bucketName = event['Records'][0]['s3']['bucket']['name']
  objectKey = event['Records'][0]['s3']['object']['key']
  tokens = objectKey.split('/')
  videoFile = tokens[len(tokens)-1]
  videoUrl = 'https://s3.amazonaws.com/' + bucketName + '/' + objectKey
  outputPath = bucketName + '/thumbnail'
  outputFilename = 'thumbnail_' + videoFile+ '_' + timestr + '_' + str(randomNumber) + '.png'
  
  print('bucketName: ' + bucketName)
  print('objectKey: ' + objectKey)
  print('videoUrl: ' + videoUrl)
  print('outputPath: ' + outputPath)
  print('outputFilename: ' + outputFilename)

  
  response = client.run_task(
  cluster='tom-thumb-cluster', # name of the cluster
  launchType = 'FARGATE',
  taskDefinition='tom-thumb-task', # replace with your task definition name and revision
      overrides={
        'containerOverrides': [
            {   
                'name': 'tom-thumb-container',
                'environment': [
                    {
                        'name': 'INPUT_VIDEO_FILE_URL',
                        'value': videoUrl
                    },
                    {
                        'name': 'OUTPUT_THUMBS_FILE_NAME',
                        'value': outputFilename
                    },
                ],
            },
        ],
    },
  count = 1,
  platformVersion='LATEST',
  networkConfiguration={
        'awsvpcConfiguration': {
            'subnets': [
		subnet1, subnet2
            ],
	'securityGroups': [
        	securityGroup
      	],
            'assignPublicIp': 'ENABLED'
        }
    })
  return str(response)
