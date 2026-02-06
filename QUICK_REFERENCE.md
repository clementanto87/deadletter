# Quick Reference: Azure Deployment

## 30-Second Deployment (One Command)

### PowerShell (Windows)
```powershell
.\deploy-azure.ps1
```

### Bash (Linux/Mac)
```bash
chmod +x deploy-azure.sh && ./deploy-azure.sh
```

## Testing Locally Before Deploying

### Build Docker Image
```bash
docker build -t deadletter:latest .
```

### Run Locally with Docker
```bash
docker run -p 8080:8080 deadletter:latest
```

### Or Use Docker Compose
```bash
docker-compose up
```

Access: http://localhost:8080

## After Deployment

### Get Application URL
```bash
az containerapp show \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --query properties.configuration.ingress.fqdn \
  --output tsv
```

Access URL: `https://<fqdn>`

### View Logs
```bash
az containerapp logs show \
  --name deadletter-app \
  --resource-group deadletter-rg
```

### Scale Application
```bash
az containerapp update \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --min-replicas 2 \
  --max-replicas 5
```

### Update Image
After pushing new image to registry:
```bash
az containerapp update \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --image deadletterregistry.azurecr.io/deadletter:new-tag
```

### Set Environment Variables
```bash
az containerapp update \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --env-vars LOG_LEVEL=DEBUG OUTPUT_FORMAT=JSON
```

## Troubleshooting

### Application won't start
```bash
# Check logs for errors
az containerapp logs show --name deadletter-app --resource-group deadletter-rg

# Check image was pushed correctly
az acr repository show-tags --name deadletterregistry --repository deadletter

# Verify container registry credentials
az acr credential show --resource-group deadletter-rg --name deadletterregistry
```

### Can't access application
```bash
# Verify ingress is enabled
az containerapp show \
  --name deadletter-app \
  --resource-group deadletter-rg \
  --query properties.configuration.ingress

# Check health status
curl https://<app-fqdn>/actuator/health
```

## Clean Up

### Delete Everything
```bash
az group delete --name deadletter-rg --yes --no-wait
```

### Delete Just the Container App
```bash
az containerapp delete \
  --name deadletter-app \
  --resource-group deadletter-rg
```

## Useful Links

- **Deployment Guide**: See [AZURE_DEPLOYMENT.md](./AZURE_DEPLOYMENT.md)
- **Files Summary**: See [DEPLOYMENT_FILES_SUMMARY.md](./DEPLOYMENT_FILES_SUMMARY.md)
- **Docker Compose**: See [docker-compose.yml](./docker-compose.yml)
- **Azure Docs**: https://learn.microsoft.com/azure/container-apps/

## Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Port already in use (local testing) | Change local port: `docker run -p 8081:8080` |
| Image pull errors | Check registry credentials with ACR credential show |
| Application timeout | Increase health check timeouts in Dockerfile |
| High costs | Lower min replicas or use lower resource allocation |
| Deployment failures | Check logs and verify Registry credentials |

---
**For detailed guide, see:** [AZURE_DEPLOYMENT.md](./AZURE_DEPLOYMENT.md)
