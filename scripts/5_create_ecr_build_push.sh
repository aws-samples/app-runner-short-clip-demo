#!/bin/bash

set -e

REPO_NAME='app-runner-demo-app'
AWS_REGION='us-east-1'
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

check=$(aws ecr describe-repositories --region ${AWS_REGION} --repository-name ${REPO_NAME} | jq -r .repositories[].repositoryName | wc -l)
if [[ $check -eq 0 ]]; then
    echo "Creating an ECR repositoy"
    ECR_REPO_URI=$(aws ecr create-repository --repository-name ${REPO_NAME} --region ${AWS_REGION} --query 'repository.repositoryUri' --output text)
else
    echo "Getting ECR repository URI"
    ECR_REPO_URI=$(aws ecr describe-repositories --repository-names ${REPO_NAME} --region ${AWS_REGION} --query 'repositories[].repositoryUri' --output text)
fi

cd `git rev-parse --show-toplevel`

echo "Building Docker image"
docker build -t ${ECR_REPO_URI} .

echo "Login to ECR"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "Pushing docker image"
docker push ${ECR_REPO_URI}

cd `git rev-parse --show-toplevel`/scripts