#!/bin/bash
#
# Stress test will use wrk, a HTTP benchmarking tool
# https://github.com/wg/wrk
# Installation using homebrew, brew install wrk
#

# Required environment variables
APP=app-runner-demo-application
AWS_REGION=us-east-1
CONCURRENT=25
DURATION=3000
THREAD=2

# Query our app runner URL
URL=$(aws apprunner list-services --region ${AWS_REGION} --query "ServiceSummaryList[?ServiceName=='$APP'] | [:1].ServiceUrl" --output text --no-cli-pager)
echo "Will run a stress test on $APP endpoint https://${URL}/"

# Run the tool, and head over to app runner console metrics tab, scroll to see "Active instances"
wrk -c $CONCURRENT -d $DURATION -t $THREAD https://${URL}/