# Getting Azure Registry Secrets - Step by Step

## 📋 Your Setup Information

**Repository:** https://github.com/clementanto87/deadletter  
**Azure Resource Group:** `deadletter-rg`  
**Azure Container Registry:** `deadletterregistry`  
**Region:** `eastus`

---

## 🚀 Step 1: Create Azure Resources (If Not Already Done)

### Option A: Using PowerShell Script
```powershell
cd c:\Users\Clement-Anto.Mariane\Desktop\workspaces\kotlin-deadletter
.\deploy-azure.ps1
```

### Option B: Using Bash Script (Linux/Mac)
```bash
cd ~/path/to/kotlin-deadletter
chmod +x deploy-azure.sh
./deploy-azure.sh
```

### Option C: Manual Azure CLI
```bash
# Login to Azure
az login

# Create resource group
az group create --name deadletter-rg --location eastus

# Create container registry
az acr create --resource-group deadletter-rg --name deadletterregistry --sku Basic
```

---

## 🔐 Step 2: Get Your Credentials (After Resources Are Created)

### Copy Each Command Below and Run in Terminal:

#### **Get #1: Registry Login Server URL**
```bash
az acr show \
  --resource-group deadletter-rg \
  --name deadletterregistry \
  --query loginServer \
  --output tsv
```
**You'll get something like:**
```
deadletterregistry.azurecr.io
```
✅ **Copy this** → Goes to GitHub Secret: `AZURE_REGISTRY_LOGIN_SERVER`

---

#### **Get #2: Registry Username**
```bash
az acr credential show \
  --resource-group deadletter-rg \
  --name deadletterregistry \
  --query username \
  --output tsv
```
**You'll get:**
```
deadletterregistry
```
✅ **Copy this** → Goes to GitHub Secret: `AZURE_REGISTRY_USERNAME`

---

#### **Get #3: Registry Password**
```bash
az acr credential show \
  --resource-group deadletter-rg \
  --name deadletterregistry \
  --query "passwords[0].value" \
  --output tsv
```
**You'll get a long string:**
```
ABCDef123456ABCDef123456ABCDef123456ABCDef123456ABCDef123456ABCD
```
✅ **Copy this** → Goes to GitHub Secret: `AZURE_REGISTRY_PASSWORD`

---

## 📝 Your Secrets Summary

Fill in after running commands above:

| Secret Name | Value |
|---|---|
| `AZURE_REGISTRY_LOGIN_SERVER` | `_____________________` |
| `AZURE_REGISTRY_USERNAME` | `deadletterregistry` |
| `AZURE_REGISTRY_PASSWORD` | `_____________________` |

---

## 🌐 Step 3: Add Secrets to GitHub

### Via GitHub Web Interface:

1. Go to: https://github.com/clementanto87/deadletter

2. Click **Settings** (top menu)

3. Left sidebar: **Secrets and variables** → **Actions**

4. Click **"New repository secret"** button

5. **First Secret:**
   - Name: `AZURE_REGISTRY_LOGIN_SERVER`
   - Value: (paste the login server URL from Get #1)
   - Click **Add secret**

6. **Second Secret:**
   - Name: `AZURE_REGISTRY_USERNAME`
   - Value: (from Get #2 - usually `deadletterregistry`)
   - Click **Add secret**

7. **Third Secret:**
   - Name: `AZURE_REGISTRY_PASSWORD`
   - Value: (paste the long password from Get #3)
   - Click **Add secret**

---

## ✅ Verification

After adding secrets, you should see:

```
✓ AZURE_REGISTRY_LOGIN_SERVER
✓ AZURE_REGISTRY_USERNAME
✓ AZURE_REGISTRY_PASSWORD
```

All three marked with green checkmarks on this page:
https://github.com/clementanto87/deadletter/settings/secrets/actions

---

## 🧪 Test It Works

1. Go to: https://github.com/clementanto87/deadletter/actions

2. Click on **"Build and Push to ACR"** workflow

3. Click **"Run workflow"**

4. Select branch: **main**

5. Click green **"Run workflow"** button

6. Watch the build progress - should succeed this time!

---

## 📊 What Each Secret Is Used For

| Secret | Used For | Example |
|---|---|---|
| `AZURE_REGISTRY_LOGIN_SERVER` | Docker registry endpoint | `deadletterregistry.azurecr.io` |
| `AZURE_REGISTRY_USERNAME` | Authentication username | `deadletterregistry` |
| `AZURE_REGISTRY_PASSWORD` | Authentication password | `ABCDef123456...` |

These are used in the workflow to:
- **Login** to Azure Container Registry
- **Push** Docker images built from your code
- **Tag** images with commit SHA and "latest"

---

## 🔒 Security Notes

- ✅ Secrets are encrypted by GitHub
- ✅ Only visible to repository collaborators with admin access
- ✅ Never printed in workflow logs
- ✅ Can be rotated anytime via Azure CLI
- ✅ Use least-privilege credentials when possible

---

## 🆘 Troubleshooting

### Issue: "Command not found: az"
**Solution:** Install Azure CLI from: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli

### Issue: "ResourceGroupNotFound"
**Solution:** Run deployment script first to create resources:
```powershell
.\deploy-azure.ps1
```

### Issue: "No subscription found"
**Solution:** Login to Azure first:
```bash
az login
```

### Issue: "Unauthorized" when pushing image
**Solution:** Verify password is correct (get fresh copy from Azure):
```bash
az acr credential show --resource-group deadletter-rg --name deadletterregistry --query "passwords[0].value" --output tsv
```

---

## 📚 Quick Links

- [Azure CLI Install](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [GitHub Secrets Docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [ACR Credential Reference](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication)
- [Docker Authentication](https://docs.docker.com/engine/reference/commandline/login/)

---

## 🎯 Next Steps

1. ✅ Deploy Azure resources (if not done)
2. ✅ Run Azure CLI commands to get credentials
3. ✅ Add 3 secrets to GitHub
4. ✅ Trigger GitHub Actions workflow
5. ✅ Verify Docker image in Azure Container Registry

Your workflow should then automatically build and push Docker images on every push to `main` branch!
