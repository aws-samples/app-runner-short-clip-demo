#!/bin/bash

set -e

REPO_NAME='app-runner-demo-app'
REGION='eu-west-1'
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

echo "Creating an ECR repositoy"
ECR_REPO_URI=$(aws ecr create-repository --repository-name ${REPO_NAME} --region ${REGION} --query 'repository.repositoryUri' --output text)

echo "Building Docker image"
docker build -t ${ECR_REPO_URI} .

echo "Logging in to ECR"
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.eu-west-1.amazonaws.com

echo "Pushing docker image"
docker push ${ECR_REPO_URI}