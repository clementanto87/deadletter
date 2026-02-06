# How to Get GitHub Actions Secrets & Azure Registry Information

## 📋 Environment Variables Explained

The GitHub Actions workflow needs these environment variables:

```yaml
REGISTRY_LOGIN_SERVER: ${{ secrets.AZURE_REGISTRY_LOGIN_SERVER }}
REGISTRY_USERNAME: ${{ secrets.AZURE_REGISTRY_USERNAME }}
REGISTRY_PASSWORD: ${{ secrets.AZURE_REGISTRY_PASSWORD }}
IMAGE_NAME: deadletter              # Fixed value - your image name
IMAGE_TAG: ${{ github.sha }}        # Automatic - Git commit SHA
```

---

## 🔑 Step 1: Get Azure Registry Credentials

### Prerequisites:
- Azure CLI installed: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
- Logged into Azure: `az login`

### Open Terminal and Run These Commands:

#### **Command 1: Get Registry URL (LOGIN_SERVER)**
```bash
az acr show \
  --resource-group deadletter-rg \
  --name deadletterregistry \
  --query loginServer \
  --output tsv
```

**Example Output:**
```
deadletterregistry.azurecr.io
```

**Copy this value** → This is your `AZURE_REGISTRY_LOGIN_SERVER`

---

#### **Command 2: Get Username & Password**
```bash
az acr credential show \
  --resource-group deadletter-rg \
  --name deadletterregistry \
  --output json
```

**Example Output:**
```json
{
  "passwords": [
    {
      "name": "password",
      "value": "your-very-long-password-here..."
    },
    {
      "name": "password2",
      "value": "second-password..."
    }
  ],
  "username": "deadletterregistry"
}
```

**Copy these values:**
- `username` → This is your `AZURE_REGISTRY_USERNAME`
- `passwords[0].value` → This is your `AZURE_REGISTRY_PASSWORD`

---

#### **Alternative: Get Each Value Separately**

```bash
# Get just the username
az acr credential show \
  --resource-group deadletter-rg \
  --name deadletterregistry \
  --query username \
  --output tsv
```

```bash
# Get just the password
az acr credential show \
  --resource-group deadletter-rg \
  --name deadletterregistry \
  --query "passwords[0].value" \
  --output tsv
```

---

## 🔐 Step 2: Add GitHub Secrets

### Method 1: Via GitHub Web UI (Recommended)

1. **Go to your GitHub repository:**
   - https://github.com/clementanto87/deadletter

2. **Navigate to Settings:**
   - Click **Settings** tab (top right)
   - Left sidebar → **Secrets and variables** → **Actions**

3. **Click "New repository secret" button**

4. **Add Secret 1: AZURE_REGISTRY_LOGIN_SERVER**
   - **Name:** `AZURE_REGISTRY_LOGIN_SERVER`
   - **Value:** `deadletterregistry.azurecr.io`
   - Click **Add secret**

5. **Add Secret 2: AZURE_REGISTRY_USERNAME**
   - **Name:** `AZURE_REGISTRY_USERNAME`
   - **Value:** `deadletterregistry`
   - Click **Add secret**

6. **Add Secret 3: AZURE_REGISTRY_PASSWORD**
   - **Name:** `AZURE_REGISTRY_PASSWORD`
   - **Value:** (paste the long password from Azure)
   - Click **Add secret**

### Result Screen:
```
✓ AZURE_REGISTRY_LOGIN_SERVER (updated recently)
✓ AZURE_REGISTRY_USERNAME (updated recently)
✓ AZURE_REGISTRY_PASSWORD (updated recently)
```

---

### Method 2: Via GitHub CLI (Alternative)

```bash
# Install GitHub CLI: https://cli.github.com/

# Login to GitHub
gh auth login

# Add secrets
gh secret set AZURE_REGISTRY_LOGIN_SERVER --body "deadletterregistry.azurecr.io"
gh secret set AZURE_REGISTRY_USERNAME --body "deadletterregistry"
gh secret set AZURE_REGISTRY_PASSWORD --body "your-password-here"
```

---

## 📊 Complete Reference Table

| Workflow Variable | GitHub Secret Name | Where to Get | Example Value |
|---|---|---|---|
| `REGISTRY_LOGIN_SERVER` | `AZURE_REGISTRY_LOGIN_SERVER` | `az acr show ... --query loginServer` | `deadletterregistry.azurecr.io` |
| `REGISTRY_USERNAME` | `AZURE_REGISTRY_USERNAME` | `az acr credential show ... --query username` | `deadletterregistry` |
| `REGISTRY_PASSWORD` | `AZURE_REGISTRY_PASSWORD` | `az acr credential show ... --query "passwords[0].value"` | `very-long-random-string...` |
| `IMAGE_NAME` | *(Not a secret - hardcoded)* | Set in workflow file | `deadletter` |
| `IMAGE_TAG` | *(Not a secret - automatic)* | GitHub automatically sets | `abc123def456...` |

---

## ✅ Verification Checklist

- [ ] Ran `az login` and authenticated to Azure
- [ ] Got `AZURE_REGISTRY_LOGIN_SERVER` from Azure
- [ ] Got `AZURE_REGISTRY_USERNAME` from Azure
- [ ] Got `AZURE_REGISTRY_PASSWORD` from Azure
- [ ] Added all 3 secrets to GitHub repository
- [ ] Secrets are visible in Settings > Secrets > Actions

---

## 🧪 Test Your Setup

1. **Trigger GitHub Actions:**
   - Go to: https://github.com/clementanto87/deadletter/actions
   - Select **"Build and Push to ACR"**
   - Click **"Run workflow"**

2. **Check the logs:**
   - Watch for "Login to Azure Container Registry" step
   - Should see: `✓ Login to Azure Container Registry`

3. **Verify image in Azure:**
   ```bash
   az acr repository list \
     --name deadletterregistry \
     --output table
   ```

   Should show: `deadletter`

4. **Check image tags:**
   ```bash
   az acr repository show-tags \
     --registry deadletterregistry \
     --repository deadletter
   ```

   Should show tags like: `abc123def456...`, `latest`

---

## 🚀 What Happens After You Add Secrets

1. **Push code to main branch** (or manually trigger workflow)
2. **GitHub Actions runs:**
   - Builds Java application with Gradle
   - Creates Docker image
   - Logs into Azure Container Registry (using your secrets)
   - Pushes image with tags (commit SHA + "latest")
3. **Image available in ACR** for deployment to Container Apps

---

## 🔒 Security Best Practices

✅ **Do:**
- Store passwords in GitHub Secrets (not in code)
- Use unique passwords/credentials per environment
- Rotate credentials periodically
- Use least privilege permissions

❌ **Don't:**
- Commit secrets to Git
- Share credentials in chat/email
- Use the same credentials everywhere
- Log secrets in workflow output

---

## 🐛 Troubleshooting

### Issue: "Login failed to Azure Container Registry"
**Solution:** Check if secrets are added correctly
```bash
# Verify credentials work locally
docker login deadletterregistry.azurecr.io -u deadletterregistry -p YOUR_PASSWORD
```

### Issue: "Unknown error accessing the registry"
**Solution:** Verify registry name is correct
```bash
az acr list --output table
```

### Issue: "Docker image push failed"
**Solution:** Check if IMAGE_NAME and IMAGE_TAG are set correctly
- `IMAGE_NAME` should be: `deadletter`
- `IMAGE_TAG` should be: commit SHA or "latest"

---

## 📚 Related Commands

```bash
# Test Azure connection
az account show

# List container registries
az acr list --output table

# Check registry admin credentials
az acr credential show --name deadletterregistry --output table

# Manually push image to ACR (for testing)
docker tag deadletter:latest deadletterregistry.azurecr.io/deadletter:latest
docker push deadletterregistry.azurecr.io/deadletter:latest

# View images in ACR
az acr repository list --name deadletterregistry

# View image tags
az acr repository show-tags --registry deadletterregistry --repository deadletter
```

---

## ✨ Quick Setup Summary

1. **Terminal: Get Credentials**
   ```bash
   az acr show --resource-group deadletter-rg --name deadletterregistry --query loginServer --output tsv
   az acr credential show --resource-group deadletter-rg --name deadletterregistry --output json
   ```

2. **GitHub: Add Secrets**
   - Go to: Settings → Secrets and variables → Actions
   - Add 3 secrets with values from step 1

3. **GitHub: Test Workflow**
   - Go to: Actions → "Build and Push to ACR" → Run workflow

Done! 🎉

---

## 📖 Additional Resources

- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [Azure Container Registry Docs](https://learn.microsoft.com/en-us/azure/container-registry/)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Docker Authentication](https://docs.docker.com/engine/reference/commandline/login/)
