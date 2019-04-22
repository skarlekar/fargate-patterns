# tom-thumb
To demonstrate invoking a long-running Fargate task on demand using Lambda

git clone https://github.com/skarlekar/tom-thumb.git
cd bean-counter-service/pre-requisites/

# Start of Prerequisites
./prereqs-ubuntu.sh
aws configure set default.region us-east-1
aws configure set default.output json

# Create ecsTaskExecutionRole and taskRole in IAM and note down the ARNs
source ./create-roles.sh

# Create VPC, Subnets and Security groups for running Fargate
source ./create-vpc-subnets.sh

# Create the ALB
source ./create-alb.sh

# ------------------ End of prerequisites

# Create the ECR Repository
source ./create-tom-thumb-repository.sh

# Build Docker image and push to ECR repository
./push-to-ecr.sh

# Create the bean counter log group
./create-tom-thumb-log-group.sh

# Create the bean counter cluster
./create-tom-thumb-cluster.sh


# Generate bean counter task definition from the template
./generate-tom-thumb-task-definition.sh <videoFileUrl> <position-in-secs>

# Register the bean counter task definition
./register-tom-thumb-task.sh

# Generate the run params for running the task
./generate-run-tom-thumb-task.sh <videoFileUrl> <position-in-secs>

# Run the task
./run-tom-thumb-task.sh

# Verify the results

# Use a lambda to trigger the task
cd lambda

# Identify a bucket that will notify the lambda when a video file is uploaded. Note down its ARN and set the S3_BUCKET_ARN variable.
EXPORT S3_BUCKET_ARN=arn:aws:s3:::your-bucket-name

# Create the policies and roles required for the lambda to invoke the Fargate task
source ./create-lambda-role.sh

# Create the log group required for the lambda to post logs to CloudWatch
./create-task-runner-log-group.sh

# Package the python code that has the function that will be triggered when a video file is uploaded
./package-lambda.sh

# Create the lambda code from the zipped source code from the above step
./create-lambda.sh

# S3 setup
# Create a folder called 'video', 'thumbnail' and 'raw' in the S3 bucket that will be used for this project.

# In the Console go to the Advanced Settings in the Properties tab of the bucket and create a notification event when a file is dropped into a particular folder in your S3 bucket.

# Upload a video file in the 'video' folder of the bucket and verify a thumbnail is created in the 'thumbnail' folder. It will take around a minute for the process to complete depending upon the size of the video file.
