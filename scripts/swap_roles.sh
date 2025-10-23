#!/bin/bash
REGION="ap-northeast-2"
SERVICE_NAME_TAG="asg-test"

echo "Swapping roles for $SERVICE_NAME_TAG..."

# 1. 현재 'role=blue'인 인스턴스 ID 찾기
OLD_BLUE_ID=$(aws ec2 describe-instances --region $REGION \
  --filters "Name=tag:service-name,Values=$SERVICE_NAME_TAG" "Name=tag:role,Values=blue" \
  --query "Reservations[].Instances[].InstanceId" --output text)

# 2. 이 스크립트가 실행 중인 인스턴스 ID 찾기
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
NEW_BLUE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v "http://169.254.169.254/latest/meta-data/instance-id")

if [ -z "$OLD_BLUE_ID" ] || [ -z "$NEW_BLUE_ID" ]; then
  echo "Failed to find Old Blue or New Blue instance IDs."
  exit 1
fi

echo "Changing OLD Blue ($OLD_BLUE_ID) to role=green"
aws ec2 create-tags --resources $OLD_BLUE_ID --tags Key=role,Value=green --region $REGION

echo "Changing NEW Blue ($NEW_BLUE_ID) to role=blue"
aws ec2 create-tags --resources $NEW_BLUE_ID --tags Key=role,Value=blue --region $REGION

echo "Role swap complete."
exit 0