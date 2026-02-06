# Azure Container Apps Deployment Script (PowerShell)
# This script builds and deploys the Kotlin Dead Letter application to Azure Container Apps

$ErrorActionPreference = "Stop"

# Configuration
$resourceGroup = "deadletter-rg"
$containerAppName = "deadletter-app"
$containerRegistry = "deadletterregistry"
$azureRegion = "eastus"
$imageName = "deadletter"
$imageTag = "latest"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure Container Apps Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az version -o json | ConvertFrom-Json
    Write-Host "✓ Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
}
catch {
    Write-Host "✗ Error: Azure CLI is not installed." -ForegroundColor Red
    Write-Host "Please install it from: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
}

# Check if user is logged in
try {
    $account = az account show -o json | ConvertFrom-Json
    Write-Host "✓ Logged in as: $($account.user.name)" -ForegroundColor Green
}
catch {
    Write-Host "Logging in to Azure..."
    az login
}

# Create resource group
Write-Host ""
Write-Host "Creating resource group: $resourceGroup..." -ForegroundColor Yellow
az group create `
    --name $resourceGroup `
    --location $azureRegion `
    --output none

# Create container registry
Write-Host "Creating container registry: $containerRegistry..." -ForegroundColor Yellow
az acr create `
    --resource-group $resourceGroup `
    --name $containerRegistry `
    --sku Basic `
    --output none

# Get registry details
Write-Host "Retrieving registry details..." -ForegroundColor Yellow
$registryUrl = (az acr show --resource-group $resourceGroup --name $containerRegistry --query loginServer -o tsv)
Write-Host "✓ Registry URL: $registryUrl" -ForegroundColor Green

# Build and push Docker image
Write-Host ""
Write-Host "Building and pushing Docker image to ACR..." -ForegroundColor Yellow
az acr build `
    --registry $containerRegistry `
    --image "${imageName}:${imageTag}" `
    .

# Get registry credentials
Write-Host "Retrieving registry credentials..." -ForegroundColor Yellow
$registryUsername = (az acr credential show --resource-group $resourceGroup --name $containerRegistry --query username -o tsv)
$registryPassword = (az acr credential show --resource-group $resourceGroup --name $containerRegistry --query "passwords[0].value" -o tsv)

# Create managed environment if it doesn't exist
Write-Host "Setting up managed environment..." -ForegroundColor Yellow
$envName = "managed-env"
$subscriptionId = (az account show --query id -o tsv)

try {
    az containerapp env show --name $envName --resource-group $resourceGroup -o none 2>$null
}
catch {
    Write-Host "Creating managed environment..." -ForegroundColor Yellow
    az containerapp env create `
        --name $envName `
        --resource-group $resourceGroup `
        --location $azureRegion `
        --output none
}

$envId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.App/managedEnvironments/$envName"

# Create or update container app
Write-Host ""
Write-Host "Creating/updating container app: $containerAppName..." -ForegroundColor Yellow

try {
    az containerapp show --name $containerAppName --resource-group $resourceGroup -o none 2>$null
    
    # Update existing app
    az containerapp update `
        --name $containerAppName `
        --resource-group $resourceGroup `
        --image "${registryUrl}/${imageName}:${imageTag}" `
        --output none
}
catch {
    # Create new app
    az containerapp create `
        --name $containerAppName `
        --resource-group $resourceGroup `
        --image "${registryUrl}/${imageName}:${imageTag}" `
        --environment $envId `
        --registry-server $registryUrl `
        --registry-username $registryUsername `
        --registry-password $registryPassword `
        --target-port 8080 `
        --ingress external `
        --output none
}

# Get the FQDN
$appUrl = (az containerapp show --name $containerAppName --resource-group $resourceGroup --query "properties.configuration.ingress.fqdn" -o tsv)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ Container App: $containerAppName" -ForegroundColor Green
Write-Host "✓ Resource Group: $resourceGroup" -ForegroundColor Green
Write-Host "✓ Application URL: https://$appUrl" -ForegroundColor Green
Write-Host ""
