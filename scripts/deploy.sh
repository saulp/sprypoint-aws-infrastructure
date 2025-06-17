#!/bin/bash
# Author: saulperdomo at gmail 2025

# sprypoint infrastructure deployment script
# usage: ./deploy.sh [environment]

set -e

ENVIRONMENT=${1:-dev}
VALID_ENVIRONMENTS=("dev" "staging" "prod")

# validate environment
if [[ ! " ${VALID_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT} " ]]; then
    echo "Error: Invalid environment '${ENVIRONMENT}'"
    echo "Valid environments: ${VALID_ENVIRONMENTS[@]}"
    exit 1
fi

echo "deploying sprypoint infrastructure to ${ENVIRONMENT}..."

# change to environment directory
cd "environments/${ENVIRONMENT}"

# initialize terraform
echo "initializing terraform..."
terraform init

# validate configuration
echo "validating configuration..."
terraform validate

# plan deployment
echo "planning deployment..."
terraform plan -out=tfplan

# apply if plan looks good
echo "applying infrastructure changes..."
terraform apply tfplan

# clean up plan file
rm tfplan

echo "deployment to ${ENVIRONMENT} complete!"
