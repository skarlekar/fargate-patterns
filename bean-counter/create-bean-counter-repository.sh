#export ECR_REPO_URI=$(aws ecr create-repository --repository-name bean-counter |  jq '.repository.repositoryUri' | sed "s/\"//g")
aws ecr create-repository --repository-name bean-counter 
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error: Repo may already exist"
fi
export ECR_REPO_URI=$(aws ecr describe-repositories | jq '.repositories[] | if .repositoryName == "bean-counter" then .repositoryUri else null end' | grep -v null | sed "s/\"//g")


