#!/bin/bash

# Azure Container Apps Deployment Script
# This script builds and deploys the Kotlin Dead Letter application to Azure Container Apps

set -e

# Configuration
RESOURCE_GROUP="deadletter-rg"
CONTAINER_APP_NAME="deadletter-app"
CONTAINER_REGISTRY_NAME="deadletterregistry"
AZURE_REGION="eastus"
IMAGE_NAME="deadletter"
IMAGE_TAG="latest"

echo "========================================"
echo "Azure Container Apps Deployment Script"
echo "========================================"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed. Please install it first."
    echo "Visit: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo "Logging in to Azure..."
    az login
fi

# Create resource group
echo "Creating resource group: $RESOURCE_GROUP"
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$AZURE_REGION" \
    --output none || true

# Create container registry
echo "Creating container registry: $CONTAINER_REGISTRY_NAME"
az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_REGISTRY_NAME" \
    --sku Basic \
    --output none || true

# Get registry login credentials
REGISTRY_URL=$(az acr show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_REGISTRY_NAME" --query loginServer --output tsv)
echo "Registry URL: $REGISTRY_URL"

# Build and push Docker image
echo "Building and pushing Docker image..."
az acr build \
    --registry "$CONTAINER_REGISTRY_NAME" \
    --image "$IMAGE_NAME:$IMAGE_TAG" \
    .

# Get registry credentials for Container Apps
REGISTRY_USERNAME=$(az acr credential show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_REGISTRY_NAME" --query "username" --output tsv)
REGISTRY_PASSWORD=$(az acr credential show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_REGISTRY_NAME" --query "passwords[0].value" --output tsv)

# Create or update container app
echo "Creating/updating container app: $CONTAINER_APP_NAME"
az containerapp create \
    --name "$CONTAINER_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --image "${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --environment-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/managedEnvironments/managed-env" \
    --registry-server "$REGISTRY_URL" \
    --registry-username "$REGISTRY_USERNAME" \
    --registry-password "$REGISTRY_PASSWORD" \
    --target-port 8080 \
    --ingress external \
    --query properties.configuration.ingress.fqdn \
    --output tsv 2>/dev/null || \
    az containerapp update \
    --name "$CONTAINER_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --image "${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --query properties.configuration.ingress.fqdn \
    --output tsv

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo "Container App URL: https://$(az containerapp show --name "$CONTAINER_APP_NAME" --resource-group "$RESOURCE_GROUP" --query properties.configuration.ingress.fqdn --output tsv)"
