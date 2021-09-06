#!/bin/bash

SERVICE_NAME='app-runner-ecr-demo-ecr'
AWS_REGION='us-east-1'
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
DYNAMODB_TABLE='app-runner-demo-table'
APPRUNNER_ROLE_NAME='apprunner-demo-role'
APPRUNNER_ACCESS_ROLE_NAME='apprunner-demo-ecr-access-role'

# create serice configiration file
read -r -d '' SERVICE_CONFIGURATION <<EOF
{
  "ImageRepository": {
    "ImageIdentifier": "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/app-runner-demo-app:latest",
    "ImageConfiguration": {
      "RuntimeEnvironmentVariables": {
          "DYNAMODB_DEMO_TABLE": "${DYNAMODB_TABLE}",
          "NODE_ENV": "production"
        },
      "Port": "3000"
    },
    "ImageRepositoryType": "ECR"
  },
  "AutoDeploymentsEnabled": true,
  "AuthenticationConfiguration": {
    "AccessRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/${APPRUNNER_ACCESS_ROLE_NAME}"
  }
}
EOF
echo "${SERVICE_CONFIGURATION}" > serviceConfiguration.json

# create instance configuration file
read -r -d '' INSTANCE_CONFIGURATION <<EOF
{
  "Cpu": "1024",
  "Memory": "2048",
  "InstanceRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/${APPRUNNER_ROLE_NAME}"
}
EOF
echo "${INSTANCE_CONFIGURATION}" > instanceConfiguration.json

# create health check configuration file
read -r -d '' INSTANCE_CONFIGURATION <<EOF
{
  "Protocol": "TCP",
  "Path": "/",
  "Interval": 10,
  "Timeout": 5,
  "HealthyThreshold": 1,
  "UnhealthyThreshold": 2
}
EOF
echo "${INSTANCE_CONFIGURATION}" > healthCheckConfiguration.json

echo "Creating app runner service"
aws apprunner create-service \
    --service-name ${SERVICE_NAME} \
    --region ${AWS_REGION} \
    --source-configuration file://serviceConfiguration.json \
    --instance-configuration file://instanceConfiguration.json \
    --health-check-configuration file://healthCheckConfiguration.json