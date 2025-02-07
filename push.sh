#!/bin/bash
AWS_REGION="eu-central-1"
AWS_ACCOUNT_ID="879381242022"
ECR_REPOSITORY="live-streaming-app"

# Authenticate with ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build the Docker image
docker build -t $ECR_REPOSITORY:latest -f Dockerfile.prod .

# Tag the Docker image
docker tag $ECR_REPOSITORY:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest

# Push the image to ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest

echo "Docker image pushed to ECR successfully!"
