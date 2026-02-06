# GitHub Actions & Git Setup Guide

## ✅ Repository Setup Complete

Your repository has been successfully initialized and pushed to GitHub:
- **Repository**: https://github.com/clementanto87/deadletter
- **Branch**: main
- **Files pushed**: 22 files including source code, deployment scripts, and documentation

## 📁 Committed Files

### Essential Source Code
- `src/main/kotlin/com/example/deadletter/` - Application source code
- `build.gradle.kts` - Gradle build configuration with Actuator dependency
- `gradle.properties` - Gradle properties
- `settings.gradle.kts` - Gradle settings

### Docker & Deployment
- `Dockerfile` - Multi-stage Docker build
- `.dockerignore` - Docker build exclusions
- `docker-compose.yml` - Local development environment

### Azure Deployment
- `deploy-azure.ps1` - PowerShell deployment script
- `deploy-azure.sh` - Bash deployment script
- `.azure-pipelines/` - Azure Pipelines CI/CD configuration
- `AZURE_DEPLOYMENT.md` - Comprehensive deployment guide

### GitHub Actions
- `.github/workflows/build-push-acr.yml` - **NEW: GitHub Actions pipeline for ACR**

### Documentation
- `README.md` - Project readme
- `QUICK_REFERENCE.md` - Quick deployment reference
- `DEPLOYMENT_FILES_SUMMARY.md` - Files overview
- `AZURE_DEPLOYMENT.md` - Full deployment guide
- `.env.example` - Environment variables template

### Configuration
- `.gitignore` - Git ignore rules (excludes build/, .gradle/, etc.)
- `.dockerignore` - Docker build optimization

## 🔄 GitHub Actions Workflow

Your repository now has an automated GitHub Actions pipeline: **`.github/workflows/build-push-acr.yml`**

### What It Does:
1. ✅ **Triggers on**: Push to main branch (or when source code changes)
2. ✅ **Builds**: Java project using Gradle
3. ✅ **Creates Docker Image**: Builds optimized multi-stage Docker image
4. ✅ **Pushes to ACR**: Uploads image to Azure Container Registry
5. ✅ **Tags**: Uses commit SHA and "latest" tags

### Workflow Triggers:
- Push to `main` branch
- Changes to: `src/`, `build.gradle.kts`, `Dockerfile`, or workflow file
- Manual trigger via GitHub Actions UI

## 🔐 Required GitHub Secrets Setup

To enable the GitHub Actions pipeline, you must configure these secrets in your GitHub repository:

### Steps to Add Secrets:

1. **Go to your GitHub repository**
   - Navigate to: Settings → Secrets and variables → Actions

2. **Add these secrets:**

#### Secret 1: Azure Registry Login Server
- **Name**: `AZURE_REGISTRY_LOGIN_SERVER`
- **Value**: `deadletterregistry.azurecr.io`
  - (Replace with your actual registry URL if different)

#### Secret 2: Azure Registry Username
- **Name**: `AZURE_REGISTRY_USERNAME`
- **Value**: Get from Azure:
  ```bash
  az acr credential show --resource-group deadletter-rg --name deadletterregistry --query username --output tsv
  ```

#### Secret 3: Azure Registry Password
- **Name**: `AZURE_REGISTRY_PASSWORD`
- **Value**: Get from Azure:
  ```bash
  az acr credential show --resource-group deadletter-rg --name deadletterregistry --query "passwords[0].value" --output tsv
  ```

### Complete Secret Setup Example:

```yaml
# Go to: Settings → Secrets and variables → Actions
# Click "New repository secret" for each:

AZURE_REGISTRY_LOGIN_SERVER = "deadletterregistry.azurecr.io"
AZURE_REGISTRY_USERNAME = "deadletterregistry"
AZURE_REGISTRY_PASSWORD = "your-very-long-password-here"
```

## 🚀 Automated Deployment Workflow

### Scenario 1: Make Code Changes
1. Commit and push to main branch
2. GitHub Actions automatically:
   - ✅ Builds your application
   - ✅ Creates Docker image
   - ✅ Pushes to Azure Container Registry
3. Optionally deploy manually or set up auto-deployment

### Scenario 2: Manual Trigger
1. Go to GitHub repository
2. Actions tab → Select "Build and Push to ACR"
3. Click "Run workflow"
4. Select branch (main)
5. Click green "Run workflow" button

## 📊 Workflow Status

To monitor builds:
1. Go to your GitHub repository
2. Click **Actions** tab
3. View workflow runs, logs, and status

## 🔧 Customizing the Workflow

### Change Registry Endpoint
Edit `.github/workflows/build-push-acr.yml`:
```yaml
REGISTRY_LOGIN_SERVER: ${{ secrets.AZURE_REGISTRY_LOGIN_SERVER }}
```

### Change Image Name
Edit `.github/workflows/build-push-acr.yml`:
```yaml
IMAGE_NAME: deadletter
```

### Add Steps (e.g., Deploy to Container Apps)
Add after "Create Release Artifact Info" step:
```yaml
- name: Deploy to Container Apps
  run: |
    az containerapp update \
      --name deadletter-app \
      --resource-group deadletter-rg \
      --image ${{ env.REGISTRY_LOGIN_SERVER }}/${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
```

## 📝 File Structure in GitHub

```
deadletter/
├── .github/
│   └── workflows/
│       └── build-push-acr.yml          ← GitHub Actions pipeline
├── .azure-pipelines/
│   ├── ci-cd-pipeline.yml
│   ├── container-app-template.json
│   └── container-app-parameters.json
├── src/
│   └── main/
│       ├── kotlin/
│       │   └── com/example/deadletter/
│       │       ├── DeadletterApplication.kt
│       │       ├── controller/
│       │       │   └── DeadletterController.kt
│       │       └── model/
│       │           └── DeadLetter.kt
│       └── resources/
│           └── application.yml
├── Dockerfile
├── docker-compose.yml
├── build.gradle.kts
├── deploy-azure.ps1
├── deploy-azure.sh
├── AZURE_DEPLOYMENT.md
├── QUICK_REFERENCE.md
└── README.md
```

## 🔄 Git Workflow Moving Forward

### For Each Change:

```bash
# Make changes to your code
# Stage changes
git add .

# Commit with descriptive message
git commit -m "Add feature: description here"

# Push to main (triggers GitHub Actions automatically)
git push origin main

# Check GitHub Actions to verify build
# Navigate to: https://github.com/clementanto87/deadletter/actions
```

## 🐛 Troubleshooting

### Issue: GitHub Actions workflow fails
**Solution**: Check workflow logs in GitHub Actions tab for error details

### Issue: Docker image push fails
**Check**:
1. Secrets are configured correctly
2. Azure Registry credentials are valid
3. Registry exists and is accessible

### Issue: Build fails
**Check**:
1. Application builds locally: `gradle build`
2. Dockerfile builds locally: `docker build -t test:latest .`
3. All source files are committed to Git

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/)
- [GitHub Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## ✨ Next Steps

1. ✅ [Configure GitHub Secrets](https://github.com/clementanto87/deadletter/settings/secrets/actions)
   - Add AZURE_REGISTRY_LOGIN_SERVER
   - Add AZURE_REGISTRY_USERNAME
   - Add AZURE_REGISTRY_PASSWORD

2. ✅ Test the workflow
   - Make a small change to source code
   - Push to main
   - Watch GitHub Actions build and push image

3. ✅ Verify image in Azure Container Registry
   ```bash
   az acr repository show-tags --registry deadletterregistry --repository deadletter
   ```

4. ✅ Deploy to Container Apps (manual or via GitHub Actions)
   ```bash
   az containerapp update \
     --name deadletter-app \
     --resource-group deadletter-rg \
     --image deadletterregistry.azurecr.io/deadletter:latest
   ```

---
**Repository**: https://github.com/clementanto87/deadletter  
**Status**: ✅ Ready for automated CI/CD with GitHub Actions
