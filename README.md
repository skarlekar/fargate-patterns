
- [**Fargate Design Patterns**](#fargate-design-patterns)
  * [Compendium and Code Examples of AWS Fargate Patterns.](#compendium-and-code-examples-of-aws-fargate-patterns)
  * [Introduction](#introduction)
  * [What is AWS Fargate?](#what-is-aws-fargate-)
  * [Components of AWS Fargate](#components-of-aws-fargate)
    + [Task](#task)
    + [Service](#service)
    + [Cluster](#cluster)
  * [AWS Fargate - the Good, Bad & Ugly](#aws-fargate---the-good--bad---ugly)
    + [Good & Bad: Pay Per Use](#good---bad--pay-per-use)
    + [Good: Low Complexity](#good--low-complexity)
    + [Good: Better Security](#good--better-security)
    + [Good: Faster Development](#good--faster-development)
    + [Good:  Scaling](#good---scaling)
    + [Bad: Limited Availability](#bad--limited-availability)
  * [Behavioral Design Patterns for AWS Fargate](#behavioral-design-patterns-for-aws-fargate)
  * [Container-on-Demand Pattern](#container-on-demand-pattern)
    + [Context & Problem](#context---problem)
    + [Solution](#solution)
      - [Pattern Components](#pattern-components)
    + [Limitations](#limitations)
  * [Scaling Container Pattern](#scaling-container-pattern)
    + [Context & Problem](#context---problem-1)
    + [Solution](#solution-1)
      - [Pattern Components](#pattern-components-1)
  * [Sidecar Assembly Pattern](#sidecar-assembly-pattern)
    + [Problem](#problem)
    + [Solution](#solution-2)
  * [Instructions for Running the Examples](#instructions-for-running-the-examples)
    + [Prerequisites](#prerequisites)
      - [AWS IAM setup for executing the AWS CLI commands](#aws-iam-setup-for-executing-the-aws-cli-commands)
      - [Development Environment setup](#development-environment-setup)
      - [Create AWS roles for Fargate](#create-aws-roles-for-fargate)
      - [Create VPC, Subnets and Security Group](#create-vpc--subnets-and-security-group)
      - [Create an Application Load Balancer](#create-an-application-load-balancer)
  * [Examples](#examples)
    + [Tom Thumb - A Video Thumbnail Generator Task](#tom-thumb---a-video-thumbnail-generator-task)
    + [Setup Instructions](#setup-instructions)
      - [Create a repository in ECR](#create-a-repository-in-ecr)
      - [Build the Docker Image](#build-the-docker-image)
      - [Create the Log Group](#create-the-log-group)
      - [Create the ECS Cluster](#create-the-ecs-cluster)
      - [Generate the Task Definition](#generate-the-task-definition)
      - [Register the Task Definition](#register-the-task-definition)
      - [Generate the parameters for running the task](#generate-the-parameters-for-running-the-task)
      - [Manually run the task](#manually-run-the-task)
      - [Create a Lambda Trigger](#create-a-lambda-trigger)
      - [Set the S3 bucket ARN](#set-the-s3-bucket-arn)
      - [Create Lambda](#create-lambda)
      - [Create a Log Group for Lambda](#create-a-log-group-for-lambda)
      - [Package the Lambda](#package-the-lambda)
      - [Deploy the Lambda](#deploy-the-lambda)
      - [Testing Tom-Thumb](#testing-tom-thumb)
    + [Bean-counter - A Coin Counter Service](#bean-counter---a-coin-counter-service)
    + [Setup Instructions](#setup-instructions-1)
      - [Create a repository in ECR](#create-a-repository-in-ecr-1)
      - [Build the Docker Image](#build-the-docker-image-1)
      - [Create the Log Group](#create-the-log-group-1)
      - [Create the ECS Cluster](#create-the-ecs-cluster-1)
      - [Generate the Task Definition](#generate-the-task-definition-1)
      - [Register the Task Definition](#register-the-task-definition-1)
      - [Generate the Service Definition](#generate-the-service-definition)
      - [Create the Bean-counter Service](#create-the-bean-counter-service)
      - [Testing the Bean-counter Service](#testing-the-bean-counter-service)
      - [Set the Scaling Policy for the Service](#set-the-scaling-policy-for-the-service)
      - [Test the Scaling Policy](#test-the-scaling-policy)
  * [Conclusion](#conclusion)
    + [Scenarios where Fargate is most Beneficial](#scenarios-where-fargate-is-most-beneficial)
    + [Scenarios where Fargate may not be the Best Choice](#scenarios-where-fargate-may-not-be-the-best-choice)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

# Fargate Design Patterns

## Compendium and Code Examples of AWS Fargate Patterns.

This is a companion project for my blog post on Fargate Patterns.

You can find the code examples, prerequisites and installation instructions here.

---


## Instructions for Running the Examples
### Prerequisites 
All the examples require a few prerequisites to be performed. These range from creating appropriate roles in IAM for the Lambda and Fargate to invoke AWS services. For instance, the Lambda to invoke the Fargate task, the Fargate task to read files from the S3 bucket and write back responses to it. Additionally, the S3 bucket must be prepped to notify the Lambda function.

> All these examples use AWS CLI to invoke various AWS services. To
> avoid the idiosyncrasies of personal development environments,  an EC2
> instance running Ubuntu 16.04 LTS was used to run the AWS CLI and
> deploy the AWS services.
> 
> As you run the various shell scripts indicated in the instructions,
> pay close attention to scripts requiring you to *source* shell
> scripts. This is done to carry over the environment variables
> generated in one script to subsequent ones.

#### AWS IAM setup for executing the AWS CLI commands
To be able to run the aws cli commands in the following exercises, create a group in IAM with the following permissions as shown below and assign it to the IAM user you will be using to work on this exercise.

![FargateDeveloper Group](https://github.com/skarlekar/fargate-patterns/blob/master/images/FargateDeveloperGroup.png)

#### Development Environment setup
Start a brand new EC2 instance running Ubuntu 16.04 LTS as your development environment and in the terminal window clone the Git repository to your development environment

    $ git clone https://github.com/skarlekar/fargate-patterns.git

 Run the *prereqs-ubuntu.sh* script to install Docker, Python, pip, AWS CLI and other development enablers in your environment.

    $ cd fargate-patterns/prerequisities
    $ prereqs-ubuntu.sh

Log out of your shell and log back for the newly installed programs to take effect.

Verify that you are able to run AWS CLI in your newly minted environment

    $ aws --version
    aws-cli/1.16.144 Python/2.7.10 Darwin/18.5.0 botocore/1.12.134

####  Create AWS roles for Fargate
Create AWS roles ecsTaskExecutionRole and task roles in IAM for Fargate to access other AWS services on your behalf

    $ source ./create-roles.sh

Ensure the role was created by verifying the TASK_ROLE_ARN variable was set

    $ echo $TASK_ROLE_ARN

####  Create VPC, Subnets and Security Group
Create VPC, Subnets and Security groups for running Fargate

    $ source ./create-vpc-subnets.sh

Ensure the role was created by verifying the VPC, SUBNET1, SUBNET2 and SECURITYGROUP variables was set.

    $ echo echo $VPC, $SUBNET1, $SUBNET2, $SECURITYGROUP

#### Create an Application Load Balancer
Create an application load balancer for the Bean-Counter service we will create later

    $ source ./create-alb.sh

Ensure the ALB, Target Group and Listener were created successfully.

    $ echo $ALB_ARN $TG_ARN $LISTENER_ARN

Do not close the terminal or the shell. You will need the environment variables for running the commands below in the examples.

## Examples
The following code examples demonstrate these behavioral patterns.

### Tom Thumb - A Video Thumbnail Generator Task
Tom Thumb is a video thumbnail generator task. It is implemented following the ***Container-on-Demand*** pattern.

In typical usage, a user uploads a video file to an S3 bucket. A trigger is set on the S3 bucket to notify a Lambda function in the event of a file upload to the *video* folder in the bucket. The Lambda is deployed with a Python code to extract the name of the video file from the Lambda notification event and [invoke a Fargate task](https://github.com/skarlekar/tom-thumb/blob/85f5dc8527ed9c8b917119ee4f94cd61621e1b42/lambda/lambda-function.py#L29-L63). The Fargate task consists of one container that uses FFmpeg application to decode the video and freeze an image at a given position in the video. The frozen image is written to a pre-configured folder in an S3 bucket.

### Setup Instructions

In the same shell that you used to run the prerequisites, run the following commands.

#### Create a repository in ECR 
Create a repository in ECR for storing the Tom-Thumb container image

    $ source ./create-tom-thumb-repository.sh

If the repository already exists, you will get an error message. This is expected. Make sure that the variable ECR_REPO_URI is set

    $ echo $ECR_REPO_URI

#### Build the Docker Image
Build a Docker image and push to ECR repository

    $ ./push-to-ecr.sh

Ensure the latest image was pushed to the ECR Repository.

![ECR Repository](https://github.com/skarlekar/fargate-patterns/blob/master/images/ecr-repository-tom-thumb.png) 

#### Create the Log Group
Create the tom-thumb log group

    $ ./create-tom-thumb-log-group.sh

This will create a log group called */ecs/tom-thumb-service*

#### Create the ECS Cluster
Create the tom-thumb cluster in ECS

    $ ./create-tom-thumb-cluster.sh

This will create an ECS cluster called tom-thumb-cluster.
![Tom-Thumb Cluster Creation](https://github.com/skarlekar/fargate-patterns/blob/master/images/cluster-creation-tom-thumb.png)

#### Generate the Task Definition
Generate tom-thumb task definition from the template by passing an URL for a sample video and the duration in the video where you want the frame captured for the thumbnail.

    $ ./generate-tom-thumb-task-definition.sh https://s3.amazonaws.com/your-bucket-name/raw/samplevideo.mp4 10

This will create a temp directory and write the *register-tom-thumb-task-definition.json* file.  Inspect this file and notice that the task contains one container and it uses the my-ecs-tasks-role you created earlier to run the Fargate task.

> Referring to  [the ECS
> documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html)
> you can see that the execution role is the IAM role that executes ECS
> actions such as pulling the image and storing the application logs in
> cloudwatch. On the other hand, the TaskRole is the IAM role used by the
> task itself. For example, if your container wants to call other AWS
> services like S3, Lambda, etc,  it uses the permissions from the
> TaskRole to perform those actions. You need the TaskRole to avoid
> storing the access keys in a config file on the container instance.

#### Register the Task Definition
Register the tom-thumb task definition in ECS and verify it has been created in the Task Definition section of ECS.

    $ ./register-tom-thumb-task.sh

![Register tom-thumb task-definition](https://github.com/skarlekar/fargate-patterns/blob/master/images/register-task-definition-tom-thumb.png)

#### Generate the parameters for running the task
Generate the parameters for running the task as follows. This will generate a file run-tom-thumb-task.json in the temp directory. 

    $ ./generate-run-tom-thumb-task.sh https://s3.amazonaws.com/your-bucket/raw/samplevideo.mp4 12 your-output-bucket

Notice that there is a section for overrides. You can make changes to this file if you want to change the parameters after the fact that the task has been registered.

#### Manually run the task
Verify the task runs and generates the thumbnail as desired.
$ ./run-tom-thumb-task.sh
Go to the tom-thumb-cluster and verify that the task is running and the thumbnail was generated.

![Manual verification of Task registration](https://github.com/skarlekar/fargate-patterns/blob/master/images/manually-run-task.png)

#### Create a Lambda Trigger
Create a Lambda to automatically trigger the Fargate Task when a video file lands in the desired bucket.

    $ cd lambda

#### Set the S3 bucket ARN
Identify a bucket that will notify the lambda when a video file is uploaded. Note down its ARN and set the S3_BUCKET_ARN variable.
$ EXPORT S3_BUCKET_ARN=arn:aws:s3:::your-bucket-name

#### Create Lambda 
Create the policies and roles required for the lambda to invoke the Fargate task. 

    $ source ./create-lambda-role.sh
    $ echo $LAMBDA_ROLE_ARN

This will create a new role called *my-run-task-lambda-role*. Verify that the role is created through the IAM section of the AWS console.

#### Create a Log Group for Lambda
Create the log group required for the lambda to post logs to CloudWatch

    $ ./create-task-runner-log-group.sh

#### Package the Lambda
Package the python code that has the function that will be triggered through the Lambda when a video file is uploaded. The following script will create a zip file with the Python code.

    $ ./package-lambda.sh

#### Deploy the Lambda
Deploy the zip file with the Lambda function on AWS. If the function already exists, it will be updated. This script also adds the permission for the Lambda to be invoked when a file is uploaded to the S3 bucket mentioned in the S3_BUCKET_ARN variable.

    $ ./create-lambda.sh

Verify the Lambda ***task-runner*** was created through the console and the following environment variables are set right for the following:

- SUBNET1
- SUBNET2
- SECURITYGROUP

Additionally, verify that the Lambda permission
Note: An update to the function does not update the environment variables. 

#### Testing Tom-Thumb
- Create a folder called 'video', 'thumbnail' and 'raw' in the S3 bucket that you chose for this project. The Bucket ARN for this should match the S3_BUCKET_ARN variable you set earlier. 

- In the Console go to the Advanced Settings in the Properties tab of the S3 bucket and create a notification event to trigger the ***task-runner*** lambda that was created earlier when a file is dropped into a particular folder in your S3 bucket.

![S3 Notification Setting 1](https://github.com/skarlekar/fargate-patterns/blob/master/images/s3-notification-setting-1.png)

![S3 Notification Setting 2](https://github.com/skarlekar/fargate-patterns/blob/master/images/s3-notification-setting-2.png)
- Upload a video file in the 'video' folder of the bucket and verify a thumbnail is created in the 'thumbnail' folder. It will take around a minute for the process to complete depending upon the size of the video file.

---
### Bean-counter - A Coin Counter Service
Bean Counter is a coin counter service. It will analyze an image of coins and return the total value of the coins in the image. It works only on US Mint issued coined and does not recognize any denomination above a quarter dollar coin. It also assumes that the picture contains a quarter. The quarter is used to calibrate the size of the coins. It is implemented following the ***Scaling-Container*** pattern.

In typical usage, a user navigates to the URL of the ALB on the browser and enters the URL for the service along with the location of the image file containing the picture of the coins. The Bean-Counter service then invokes the Fargate Task and returns the response to the browser.

### Setup Instructions

In the same shell that you used to run the prerequisites, run the following commands.

#### Create a repository in ECR 
Create a repository in ECR for storing the Tom-Thumb container image

    $ source ./create-bean-counter-repository.sh

If the repository already exists, you will get an error message. This is expected. Make sure that the variable ECR_REPO_URI is set

    $ echo $ECR_REPO_URI

#### Build the Docker Image
Build a Docker image and push to ECR repository

    $ ./push-to-ecr.sh

Ensure the latest image was pushed to the ECR Repository.

#### Create the Log Group
Create the bean-counter log group

    $ ./create-bean-counter-log-group.sh

This will create a log group called */ecs/bean-counter-service*

#### Create the ECS Cluster
Create the bean-counter cluster in ECS

    $ ./create-bean-counter-cluster.sh

This will create an ECS cluster called tom-thumb-cluster.

#### Generate the Task Definition
Generate a bean-counter task definition from the template.

    $ ./generate-bean-counter-task-definition.sh 

This will create a temp directory and write the *register-bean-counter-task-definition.json* file.  Inspect this file and notice that the task contains one container and it uses the my-ecs-tasks-role you created earlier to run the Fargate task.

#### Register the Task Definition
Register the bean-counter task definition in ECS and verify it has been created in the Task Definition section of ECS.

    $ ./register-bean-counter-task.sh

#### Generate the Service Definition
Generate a bean-counter service definition from the template.

    $ ./generate-bean-counter-service-definition.sh 

This will create a temp directory and write the *create-bean-counter-service-definition.json* file.  Inspect this file and notice that it contains the target group for the service under the load balancers section. This ties the load balancer to the service. Also, notice the desiredCount variable set to 2. 

#### Create the Bean-counter Service
Create the bean-counter service from the service definition file generated in the previous step.
$ ./create-bean-counter-service.sh

Verify that the service has been created and two tasks are being provisioned for the service.

![Bean-counter Service Creation Check](https://github.com/skarlekar/fargate-patterns/blob/master/images/create-bean-counter-service-1.png)

![Bean-counter Service Task Provision Check](https://github.com/skarlekar/fargate-patterns/blob/master/images/create-bean-counter-service-2.png)

#### Testing the Bean-counter Service
Retrieve the DNS name of the application load balancer. Cut & paste the DNS in the browser.

    $ export DNS=$(aws elbv2 describe-load-balancers | jq '.LoadBalancers[] | if .LoadBalancerName == "My-Fargate-ALB" then .DNSName else null end' | grep -v null | sed "s/\"//g")
    $ echo $DNS
    My-Fargate-ALB-xxxxxxx.us-east-1.elb.amazonaws.com

![Bean counter landing page](https://github.com/skarlekar/fargate-patterns/blob/master/images/bean-counter-browser-1.png)
![Bean counter test output](https://github.com/skarlekar/fargate-patterns/blob/master/images/bean-counter-browser-2.png)

#### Set the Scaling Policy for the Service
Set a target scaling policy for the service such that the desired count of the service is set to 2 and can increase to 4 on demand. The auto-scaling-policy.json specifies that when the combined load on the service breaches 75% the service should scale-out. A cool-out period of 60 seconds is also specified so that the service doesn't thrash around.

    $ ./set-scaling-policy.sh

#### Test the Scaling Policy
Use Apache Bench to hit the server $100,000 times with 100 concurrent threads with a timeout of 120 seconds to see the service scale out. You will have to wait for the cooling period to see the scaling out. Scaling in will take 15 minutes after scale out. Verify this on the ECS console.

    $ ./test-scaling.sh

Following is the output of running Apache Bench:    
![Output of Apache Bench](https://github.com/skarlekar/fargate-patterns/blob/master/images/auto-scaling-output.png)

In the following picture, you can see that Fargate has scaled-out as a result of the load.
![Fargate caught in action](https://github.com/skarlekar/fargate-patterns/blob/master/images/scaling-demo.png)

## Conclusion
Each application is unique and solving different needs based on business requirements. If the task of infrastructure management is too onerous and/or if you only want to pay for your computing time, then Fargate may be the right choice for you. 

On the other hand, if you need greater control of the network resources or have large container workloads that warrant maintaining a cluster of servers to run ECS or EKS, then stick with the latter.

### Scenarios where Fargate is most Beneficial
Fargate can be used with any type of containerized application. However, this doesn’t mean that you will get the same benefit in every scenario. Fargate would be most beneficial for projects that need to reduce the time from ideation to realization such as proofs-of-concept and well-designed, decoupled, micro service-based architectures deployed in production environments.

**Applications can consist of a mix of Fargate & Lambda to exploit the Serverless model.**

Use Lambdas for small & tight services with low memory (<3GB) and small request-response cycles (<15 mins).

Use containers deployed on Fargate for:
- Existing legacy services that cannot be trivially refactored, 
- Applications are written in languages not supported by Lambda,
- Need to use large libraries that cannot fit into a Lambda profile (Quantlib, Scikit, etc),
- Where you need more control over networking, compute horsepower or memory
- Use cases that require a long in-process runtime.

### Scenarios where Fargate may not be the Best Choice

- When you require greater control of your EC2 instances to support networking, COTS applications that require broader customization options, then use ECS without Fargate.
- When you want fast request-response cycle time then Lambda may be a good choice.  This is especially true if you are using large container images written with object-heavy languages such as Java/Scala that requires significant initiation time to start the JVM and bootstrap objects. 
- By breaking down your application into smaller modules that fit into Lambdas and using Layers and Step Functions you can reap the benefits of Serverless architectures while paying only for your compute time.
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE0NjYxNDA2NywtMTI0Njg5Mjk3OSwtMj
A3OTczNDQ0NywtMTgzNzM2NDE3NSwzODM0OTc3NDcsODkwNDI3
MTc3LC03ODk4NDcyNDgsMTQ4NDIzNDUxMywxMjUwNzAyNDQyLC
0xNTM0MjU4NjM1LC0xMzE4MzA3MjQ3LDk5MDQ5NjI2LDExOTAy
ODc5NzksMTc3NjI0MTI0MCwtMTcxODUxMDQzNyw4NjI0MTY3Nj
EsOTk2OTgyNTg2LDIzNjQ2Mjk0MCwtNTc3MjQzNzg5LC04NTMw
NTUxNjhdfQ==
-->