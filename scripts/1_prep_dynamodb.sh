#!/bin/bash

set -e

# Dynamodb table name
DYNAMODB_TABLE='app-runner-demo-table'
AWS_REGION='us-east-1'

# create an on demand dynamodb table
aws dynamodb create-table \
    --table-name ${DYNAMODB_TABLE} \
    --attribute-definitions AttributeName=name,AttributeType=S \
    --key-schema AttributeName=name,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region ${AWS_REGION} > /dev/null 2>&1

TABLE_STATUS="NOTREADY"

until [ "$TABLE_STATUS" == "ACTIVE" ]; do
    TABLE_STATUS=$(aws dynamodb describe-table \
        --table-name ${DYNAMODB_TABLE} \
        --query Table.TableStatus \
        --region ${AWS_REGION} \
        --output text)
    echo "Waiting for table to be in status ACTIVE"
    sleep 1
done

echo "DynamoDB table is ready"

# Set counter record in Dynamodb
aws dynamodb put-item \
    --region ${AWS_REGION} \
    --table-name ${DYNAMODB_TABLE} \
    --item '{ "name": { "S": "counter" }, "counter_count": { "N" : "0" } }'

echo "App counter set"