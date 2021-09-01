#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION='us-east-1'
APPRUNNER_POLICY_NAME='apprunner-demo-policy'
APPRUNNER_ROLE_NAME='apprunner-demo-role'
DYNAMODB_TABLE='app-runner-demo-table'

# create role
echo "Creating a new trust policy"
read -r -d '' TRUST <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "tasks.apprunner.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
echo "${TRUST}" > TrustPolicy.json

# Create Permission Policy
read -r -d '' PERMISSION_POLICY <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:${AWS_REGION}:${ACCOUNT_ID}:table/${DYNAMODB_TABLE}"
        }
    ]
}
EOF
echo "${PERMISSION_POLICY}" > PermissionPolicy.json

# create IAM Policy
IAM_POLICY_ARN=$(aws iam create-policy \
    --policy-name $APPRUNNER_POLICY_NAME \
    --policy-document file://PermissionPolicy.json \
    --query "Policy.Arn" --output text)

echo "Created policy"

# create IAM Role
APPRUNNER_IAM_ROLE_ARN=$(aws iam create-role \
  --role-name $APPRUNNER_ROLE_NAME \
  --assume-role-policy-document file://TrustPolicy.json \
  --description "$APPRUNNER_ROLE_NAME" \
  --query "Role.Arn" --output text)

echo "Created IAM Roles"

# Attach IAM policy to IAM Role
aws iam attach-role-policy --role-name $APPRUNNER_ROLE_NAME --policy-arn $IAM_POLICY_ARN  

# Attach trust policy to IAM role
aws iam update-assume-role-policy --role-name $APPRUNNER_ROLE_NAME --policy-document file://TrustPolicy.json
