#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION='us-east-1'
APPRUNNER_ROLE_NAME='apprunner-demo-ecr-access-role'
IAM_MANAGED_POLICY_ACCESS_ARN='arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess'

# create role
echo "Creating a new trust policy"
read -r -d '' TRUST <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": {
          "build.apprunner.amazonaws.com"
        }
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
echo "${TRUST}" > TrustPolicy.json

# create IAM Role
APPRUNNER_IAM_ROLE_ARN=$(aws iam create-role \
  --role-name $APPRUNNER_ROLE_NAME \
  --assume-role-policy-document file://TrustPolicy.json \
  --description "$APPRUNNER_ROLE_NAME" \
  --query "Role.Arn" --output text)

echo "Created IAM Role"

# Attach IAM policy to IAM Role
aws iam attach-role-policy --role-name $APPRUNNER_ROLE_NAME --policy-arn $IAM_POLICY_ARN  

# Attach trust policy to IAM role
aws iam update-assume-role-policy --role-name $APPRUNNER_ROLE_NAME --policy-document file://TrustPolicy.json
