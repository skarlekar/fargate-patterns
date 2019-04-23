$(aws ecr get-login --no-include-email --region us-east-1)
docker build -t bean-counter bean-counter
docker tag bean-counter:latest $ECR_REPO_URI:latest
docker push $ECR_REPO_URI:latest
