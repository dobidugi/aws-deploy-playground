#!/bin/bash

JAR_PATH="/home/ec2-user/app/asg-deploy-test.jar"
LOG_PATH="/home/ec2-user/app/app.log"

echo "Starting Spring Boot application..."

# nohup: 터미널이 끊겨도 계속 실행 (백그라운드)
# 2>&1: 에러 로그(stderr)를 일반 로그(stdout)와 함께 app.log 파일에 저장
# &: 백그라운드에서 실행
nohup sudo java -jar $JAR_PATH  --server.port=80 > $LOG_PATH 2>&1 &