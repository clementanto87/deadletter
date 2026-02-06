# Azure Deployment Files Summary

This folder contains all necessary files and configurations to deploy the Kotlin Dead Letter application to Azure Container Apps.

## Files Overview

### 1. **Dockerfile**
- Multi-stage build using Gradle builder and Eclipse Temurin JRE
- Optimized for production with minimal image size
- Includes health checks for Azure Container Apps monitoring
- Exposes port 8080

### 2. **.dockerignore**
- Excludes unnecessary files from Docker build context
- Reduces build time and image size

### 3. **docker-compose.yml**
- Local development environment configuration
- Allows testing the Docker image locally before Azure deployment
- Usage: `docker-compose up`

### 4. **Deployment Scripts**

#### **deploy-azure.ps1** (PowerShell - Windows)
- Automated deployment script for Windows users
- Creates Azure resources automatically
- Builds and pushes Docker image to ACR
- Creates/updates Container App
- Usage: `.\deploy-azure.ps1`

#### **deploy-azure.sh** (Bash - Linux/Mac)
- Automated deployment script for Linux/Mac users
- Same functionality as PowerShell version
- Usage: `chmod +x deploy-azure.sh && ./deploy-azure.sh`

### 5. **AZURE_DEPLOYMENT.md**
- Comprehensive deployment guide
- Step-by-step instructions for all deployment methods
- Troubleshooting tips
- Cost optimization strategies
- Scaling and monitoring instructions

### 6. **Azure Pipelines Configuration** (.azure-pipelines/)

#### **ci-cd-pipeline.yml**
- Azure DevOps CI/CD pipeline configuration
- Automated build, test, and deployment stages
- Builds Docker image and pushes to ACR
- Deploys to Container Apps

#### **container-app-template.json** (ARM Template)
- Infrastructure as Code for Azure resources
- Defines:
  - Container Registry
  - Managed Environment
  - Container App with scaling policies
  - Health checks and probes
  - Liveness and readiness probes

#### **container-app-parameters.json**
- Default parameters for ARM template
- Customize values as needed:
  - Container app name
  - Registry name
  - Location
  - Min/Max replicas

## Quick Start Options

### Option 1: Automated Deployment (Recommended for Beginners)

**Windows (PowerShell):**
```powershell
.\deploy-azure.ps1
```

**Linux/Mac (Bash):**
```bash
./deploy-azure.sh
```

### Option 2: Using Azure CLI (Manual)

See detailed steps in [AZURE_DEPLOYMENT.md](../AZURE_DEPLOYMENT.md)

### Option 3: Using Azure Pipelines (CI/CD)

1. Push code to Git repository
2. Create Azure DevOps project
3. Create pipeline from `.azure-pipelines/ci-cd-pipeline.yml`
4. Configure service connections
5. Run pipeline

### Option 4: Using ARM Template (Infrastructure as Code)

```bash
az deployment group create \
  --resource-group deadletter-rg \
  --template-file .azure-pipelines/container-app-template.json \
  --parameters .azure-pipelines/container-app-parameters.json
```

## Prerequisites

### For Automated Scripts:
1. Azure CLI installed
2. Azure account
3. Docker (optional, for local testing)

### For Azure Pipelines:
1. Azure DevOps account
2. Git repository
3. Service connections configured

## Project Structure After Deployment

```
Azure Resources:
├── Resource Group (deadletter-rg)
│   ├── Container Registry (deadletterregistry)
│   │   └── Image Repository (deadletter)
│   ├── Container App Environment (managed-env)
│   └── Container App (deadletter-app)
│       └── Replicas (auto-scaled 1-3)
```

## Key Features

✅ **Multi-stage Docker Build** - Optimized image size  
✅ **Health Checks** - Automatic monitoring and recovery  
✅ **Auto-scaling** - Handles traffic spikes  
✅ **Managed Environment** - No infrastructure to manage  
✅ **Private Registry** - Secure image storage  
✅ **CI/CD Ready** - Azure Pipelines integration  
✅ **Infrastructure as Code** - Reproducible deployments  

## Customization

### Environment Variables
Edit the deployment script or update the Container App:
```bash
az containerapp update \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --env-vars KEY=value
```

### Scaling Configuration
Modify `minReplicas` and `maxReplicas` in:
- `deploy-azure.ps1` / `deploy-azure.sh`
- `.azure-pipelines/container-app-parameters.json`

### Resource Allocation
Update CPU/Memory in:
- `container-app-template.json` (ARM template)
- Container App properties

## Monitoring & Logging

After deployment, monitor your application:

```bash
# View logs
az containerapp logs show \
  --name deadletter-app \
  --resource-group deadletter-rg

# View metrics
az containerapp show \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --query properties.configuration
```

## Cost Estimates

Based on Azure pricing (as of Feb 2026):

| Component | Tier | Estimated Cost |
|-----------|------|-----------------|
| Container App (0.5 vCPU) | Pay-per-use | ~$15-30/month |
| Container Registry | Basic | ~$5/month |
| Managed Environment | Included | No charge |
| **Total** | | **~$20-35/month** |

*Note: Costs vary based on compute usage and region*

## Support & Documentation

- [Azure Container Apps Docs](https://learn.microsoft.com/azure/container-apps/)
- [Azure Container Registry Docs](https://learn.microsoft.com/azure/container-registry/)
- [Spring Boot on Azure](https://learn.microsoft.com/azure/developer/java/spring-framework/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)

## Next Steps

1. ✅ Review files in this directory
2. ✅ Run deployment script or follow manual steps
3. ✅ Test application at deployed URL
4. ✅ Configure monitoring and alerts
5. ✅ Set up CI/CD pipeline (optional)

---
**Last Updated:** February 6, 2026  
**Application:** Kotlin Dead Letter Service  
**Target Platform:** Azure Container Apps
