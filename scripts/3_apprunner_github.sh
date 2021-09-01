#!/bin/bash

SERVICE_NAME=app-runner-github-demo
AWS_REGION=us-east-1
REPO_URL=https://github.com/aws-samples/app-runner-short-clip-demo
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
DYNAMODB_TABLE=app-runner-demo-table
CONNECTION_NAME=github
CONNECTION_ARN=$(aws apprunner list-connections --region ${AWS_REGION} --query "ConnectionSummaryList[?ConnectionName=='$CONNECTION_NAME'] | [:1].ConnectionArn" --output text --no-cli-pager)


# create serice configiration file
read -r -d '' SERVICE_CONFIGURATION <<EOF
{
  "CodeRepository": {
    "RepositoryUrl": "${REPO_URL}",
    "SourceCodeVersion": {
      "Type": "BRANCH",
      "Value": "main"
    },
    "CodeConfiguration": {
      "ConfigurationSource": "API",
      "CodeConfigurationValues": {
        "Runtime": "NODEJS_12",
          "BuildCommand": "npm install",
          "StartCommand": "node index.js",
          "Port": "3000",
          "RuntimeEnvironmentVariables": {
            "DYNAMODB_DEMO_TABLE": "${DYNAMODB_TABLE}",
            "NODE_ENV": "production"
          }
      }
  }
},
  "AutoDeploymentsEnabled": true,
  "AuthenticationConfiguration": {
    "ConnectionArn": "${CONNECTION_ARN}"
  }
}
EOF
echo "${SERVICE_CONFIGURATION}" > serviceConfiguration.json

# create instance configuration file
read -r -d '' INSTANCE_CONFIGURATION <<EOF
{
  "Cpu": "1024",
  "Memory": "2048",
  "InstanceRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/apprunner-demo-role"
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