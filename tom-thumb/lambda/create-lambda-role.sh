# Create a new policy to be used for ECS tasks
export POLICY_ARN=$(aws iam create-policy --policy-name my-run-task-by-lambda-policy --policy-document file://run-task-by-lambda-policy.json | jq '.Policy.Arn' | sed "s/\"//g")

# Name our new role
export LAMBDA_ROLE=my-run-task-lambda-role

# Create the role that Lambda will use to call ECS and S3 on your behalf. The services that Lambda will assume is specified in the lambda-assume-role.json file
aws iam create-role --role-name $LAMBDA_ROLE --description "Allows Lambda functions to call AWS services on your behalf"  --assume-role-policy-document file://lambda-assume-role.json

# Attach S3 access managed policy to the role created above
aws iam attach-role-policy --role-name $LAMBDA_ROLE --policy-arn $POLICY_ARN

# Retrieve the role ARN for future processing
export LAMBDA_ROLE_ARN=$(aws iam get-role --role-name $LAMBDA_ROLE | jq '.Role.Arn' | sed "s/\"//g")
echo Execution Role: $LAMBDA_ROLE_ARN captured

