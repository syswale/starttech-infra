#!/bin/bash
# StartTech Infrastructure Deployment Script

set -e

echo "Navigating to terraform directory..."
cd ../terraform

echo "Initializing Terraform..."
terraform init

echo "Validating configuration..."
terraform validate

echo "Planning deployment..."
terraform plan -out=tfplan

echo "Applying infrastructure..."
terraform apply -auto-approve tfplan

echo "Infrastructure deployment complete!"