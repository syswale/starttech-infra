#!/bin/bash
set -e

yum update -y
yum install -y docker amazon-cloudwatch-agent jq
systemctl start docker
systemctl enable docker

ECR_REGISTRY=$(echo ${ecr_image_uri} | cut -d'/' -f1)
aws ecr get-login-password --region ${aws_region} | \
  docker login --username AWS --password-stdin $ECR_REGISTRY

# SECURE FETCH: Pull MongoDB URI from SSM Vault
MONGO_URI=$(aws ssm get-parameter \
  --name "/starttech/prod/mongodb_uri" \
  --with-decryption \
  --region ${aws_region} \
  --query "Parameter.Value" \
  --output text)

docker pull ${ecr_image_uri}

docker run -d \
  --name starttech-backend \
  --restart unless-stopped \
  -p 8080:8080 \
  -e PORT=8080 \
  -e MONGO_URI="$MONGO_URI" \
  -e DB_NAME="starttech" \
  -e JWT_SECRET_KEY="${jwt_secret}" \
  -e JWT_EXPIRATION_HOURS=72 \
  -e REDIS_ADDR="${redis_endpoint}:6379" \
  -e ENABLE_CACHE=true \
  -e LOG_LEVEL=INFO \
  -e LOG_FORMAT=json \
  ${ecr_image_uri}

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CWCONFIG'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/lib/docker/containers/*/*.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/backend",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
CWCONFIG

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s