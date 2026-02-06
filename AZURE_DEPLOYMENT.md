# Azure Container Apps Deployment Guide

This guide provides step-by-step instructions to deploy the Kotlin Dead Letter application to Azure Container Apps.

## Prerequisites

1. **Azure Account**: [Create a free Azure account](https://azure.microsoft.com/free)
2. **Azure CLI**: [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
3. **Docker**: (Optional, for local testing) [Install Docker](https://www.docker.com/products/docker-desktop)

## Quick Start

### Option 1: Using PowerShell (Windows)

```powershell
# Navigate to project directory
cd your-project-path

# Make script executable (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run deployment script
.\deploy-azure.ps1
```

### Option 2: Using Bash (Linux/Mac)

```bash
# Navigate to project directory
cd your-project-path

# Make script executable
chmod +x deploy-azure.sh

# Run deployment script
./deploy-azure.sh
```

### Option 3: Manual Deployment Using Azure CLI

#### Step 1: Login to Azure
```bash
az login
```

#### Step 2: Create Resource Group
```bash
az group create --name deadletter-rg --location eastus
```

#### Step 3: Create Azure Container Registry (ACR)
```bash
az acr create --resource-group deadletter-rg --name deadletterregistry --sku Basic
```

#### Step 4: Build and Push Docker Image
```bash
az acr build --registry deadletterregistry --image deadletter:latest .
```

#### Step 5: Create Container App Environment (if not exists)
```bash
az containerapp env create \
  --name managed-env \
  --resource-group deadletter-rg \
  --location eastus
```

#### Step 6: Get Registry Credentials
```bash
az acr credential show --resource-group deadletter-rg --name deadletterregistry
```

#### Step 7: Create Container App
```bash
az containerapp create \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --image deadletterregistry.azurecr.io/deadletter:latest \
  --environment managed-env \
  --registry-server deadletterregistry.azurecr.io \
  --registry-username <USERNAME> \
  --registry-password <PASSWORD> \
  --target-port 8080 \
  --ingress external
```

Replace `<USERNAME>` and `<PASSWORD>` with values from Step 6.

## Accessing Your Application

After deployment, your application will be available at:
```
https://<app-fqdn>
```

To get the FQDN:
```bash
az containerapp show --name deadletter-app --resource-group deadletter-rg --query properties.configuration.ingress.fqdn
```

## Environment Variables

To set environment variables in Azure Container Apps:

```bash
az containerapp update \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --env-vars KEY1=value1 KEY2=value2
```

## Viewing Logs

```bash
az containerapp logs show \
  --name deadletter-app \
  --resource-group deadletter-rg \
  -n <replica-name>
```

Or use Azure Monitor:
```bash
az monitor metrics list-definitions --resource /subscriptions/<subscription-id>/resourceGroups/deadletter-rg/providers/Microsoft.App/containerApps/deadletter-app
```

## Scaling

Scale the container app:
```bash
az containerapp update \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --min-replicas 1 \
  --max-replicas 10
```

## Health Check Configuration

The Dockerfile includes a health check that monitors the application's `/actuator/health` endpoint. This requires Spring Boot Actuator to be added to the dependencies.

To add health check support:

```kotlin
// In build.gradle.kts
dependencies {
    implementation("org.springframework.boot:spring-boot-starter-actuator")
}
```

## Cleaning Up

To delete the resources:

```bash
az group delete --name deadletter-rg --yes --no-wait
```

## Cost Optimization

- **Container Registry**: Basic tier is sufficient for most scenarios
- **Container Apps**: Pricing is based on compute time (vCPU-seconds) and memory
- **Auto-scaling**: Configure scaling policies to reduce costs during off-peak hours

```bash
az containerapp scale \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --scale-rule-name http-rule \
  --scale-rule-type http \
  --scale-rule-http-concurrency 100
```

## Troubleshooting

### Application Won't Start
1. Check logs: `az containerapp logs show --name deadletter-app --resource-group deadletter-rg`
2. Verify port configuration (should be 8080)
3. Check Docker image build succeeded

### Image Pull Errors
1. Verify registry credentials
2. Ensure image tag is correct
3. Check registry name matches the image URI

### Connection Issues
1. Verify ingress is enabled: `az containerapp show --name deadletter-app --resource-group deadletter-rg --query properties.configuration.ingress`
2. Check network security groups (NSG) rules
3. Ensure target port is 8080

## Additional Resources

- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)
- [Spring Boot on Azure](https://learn.microsoft.com/azure/developer/java/spring-framework/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Support

For issues or questions:
1. Check Azure Container Apps troubleshooting guide
2. Review application logs
3. Contact Azure Support (if you have a support plan)
