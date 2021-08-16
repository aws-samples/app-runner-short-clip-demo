# app-runner short clip

The demo will show case a web app that will have access to a DynamoDB table with a counter, and will count page impressions using DynamoDB.

The short clip will demonstrate how to deploy a `nodejs` application in 2 ways:

1. Source code repository with auto deployment
2. Container registry with automatic deployment

>In the short clip I will talk on `apprunner.yaml` file that allows to custom config the application build and run.

## Setup

1. Create a DynamoDB table `1_prep_dynamodb.sh`
2. Create proper permissions for app runner task to access DynamoDB securely `2_permissions.sh`
3. Create a Github connection
4. Create a ECR repository, build and push application docker image `3_create_ecr.sh`
5. Create App Runner service with ECR auto deployment `4_apprunner_ecr.sh`, explain on the managed role `AppRunnerECRAccessRole` for pulling from ECR
6. Create App Runner service with Github hook auto deployment `5_apprunner_github.sh`
7. showing the auto deployment in both scenarios 4,5.
8. showing the auto scale with stressing the application with `wrk` using `6_stress_test.sh`
