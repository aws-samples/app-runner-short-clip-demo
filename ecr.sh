#!/bin/bash

REGION='eu-west-1'
APP='app-runner-short-clip-demo'

check=$(aws ecr describe-repositories  --region ${REGION} --repository-name ${APP} | jq -r .repositories[].repositoryName | wc -l)
if [[ $check -eq 0 ]]; then
    aws ecr --region ${REGION} create-repository --repository-name ${APP}
fi

