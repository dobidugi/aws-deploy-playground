#!/bin/bash
echo "Validating service health..."

for i in {1..10}; do

  response=$(curl -s  http://localhost:80/health)

  # 헬스 체크
  if [[ "$response" == *'"status":"UP"'* ]]; then
    echo "Service is UP! Validation successful."
    exit 0 #
  fi

  echo "Attempt $i: Service not up yet. Retrying in 5 seconds..."
  sleep 5
done

echo "Service failed to start or respond."
exit 1