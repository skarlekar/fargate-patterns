$(aws ecr get-login --no-include-email --region us-east-1)
docker build -t tom-thumb tom-thumb-task
docker tag tom-thumb:latest $ECR_REPO_URI:latest
docker push $ECR_REPO_URI:latest
