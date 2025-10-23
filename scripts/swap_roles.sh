#!/bin/bash
set -euo pipefail

REGION="ap-northeast-2"
SERVICE_NAME_TAG="asg-test"

log() { echo "[swap_roles] $*"; }

# IMDSv2로 자기 자신 ID
TOKEN=$(curl -sS --fail -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
NEW_BLUE_ID=$(curl -sS --fail -H "X-aws-ec2-metadata-token: $TOKEN" \
  "http://169.254.169.254/latest/meta-data/instance-id" | tr -d '\r')

if [[ -z "${NEW_BLUE_ID:-}" ]]; then
  log "NEW_BLUE_ID not found"; exit 1
fi
log "NEW_BLUE_ID=$NEW_BLUE_ID"

# 자기 ASG 이름(같은 ASG 안에서만 스왑하도록 제한)
ASG_NAME=$(aws autoscaling describe-auto-scaling-instances \
  --instance-ids "$NEW_BLUE_ID" --region "$REGION" \
  --query "AutoScalingInstances[0].AutoScalingGroupName" --output text 2>/dev/null || true)

if [[ -z "${ASG_NAME:-}" || "${ASG_NAME}" == "None" ]]; then
  log "ASG_NAME not found; will NOT restrict by ASG (be careful)"
else
  log "ASG_NAME=$ASG_NAME"
fi

# 이전 BLUE 후보: 같은 서비스 + (가능하면) 같은 ASG + running + 자기 자신 제외
FILTERS=( "Name=tag:service-name,Values=${SERVICE_NAME_TAG}" "Name=tag:role,Values=blue" "Name=instance-state-name,Values=running" )
if [[ -n "${ASG_NAME:-}" && "${ASG_NAME}" != "None" ]]; then
  FILTERS+=( "Name=tag:aws:autoscaling:groupName,Values=${ASG_NAME}" )
fi

OLD_BLUE_IDS=$(aws ec2 describe-instances --region "$REGION" \
  --filters "${FILTERS[@]}" \
  --query "Reservations[].Instances[?InstanceId!='${NEW_BLUE_ID}'].InstanceId" \
  --output text | tr -d '\r')

# 1) 자기 자신을 blue로 확정
log "Tagging self as role=blue (and service-name=${SERVICE_NAME_TAG})"
aws ec2 create-tags --region "$REGION" \
  --resources "$NEW_BLUE_ID" \
  --tags Key=service-name,Value="$SERVICE_NAME_TAG" Key=role,Value=blue

# 2) 이전 BLUE들을 green으로 전환
if [[ -n "${OLD_BLUE_IDS:-}" ]]; then
  log "Found previous BLUE(s): ${OLD_BLUE_IDS}. Tagging as green..."
  aws ec2 create-tags --region "$REGION" \
    --resources ${OLD_BLUE_IDS} \
    --tags Key=role,Value=green
else
  log "No previous BLUE found. (Nothing to switch)"
fi

log "Role swap complete."
exit 0
