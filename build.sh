#!/bin/bash

REGION='us-east-1'
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
APP='app-runner-short-clip-demo'

ECR="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR

docker build -t $ECR/$APP .
docker push $ECR/$APP