# Keep Helm Chart
The Keep Helm Chart provides a convenient way to deploy and manage Keep on Kubernetes using Helm, a package manager for Kubernetes applications.

# Documentation
Full documentation can be found at [Keep Docs](https://docs.keephq.dev/deployment/kubernetes/installation).

# Prerequisites

## Ingress Controller (Recommended)
The recommended way to deploy Keep is with ingress-nginx that serves as a single ingress for all services (backend, frontend, and websocket server).

1. Install ingress-nginx:
```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

2. Enable snippet annotations:
The ingress controller must have snippet annotations enabled. You can enable it during installation:
```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.config.allow-snippet-annotations=true
```

To verify if snippet annotations are enabled:
```bash
# Check the configmap
kubectl get configmap -n ingress-nginx ingress-nginx-controller -o yaml | grep allow-snippet-annotations

# Or check the controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller | grep "allow-snippet-annotations"
```

# Installation

## Option 1: With ingress-nginx (Recommended)
```bash
# Add the Helm repository
helm repo add keephq https://keephq.github.io/helm-charts

# Install Keep with ingress enabled (default nginx)
helm install keep keephq/keep -n keep --create-namespace
```

## Option 2: Without ingress-nginx (Not recommended)
Keep can be deployed without ingress-nginx, but this will create three separate ingresses (one for each service):
```bash
# Add the Helm repository
helm repo add keephq https://keephq.github.io/helm-charts

# Install Keep without ingress
helm install keep keephq/keep
```

# Post-Installation

## With ingress-nginx
Your Keep installation will be available at the ingress host you configured. Check your ingress status:
```bash
kubectl get ingress
```

## Without ingress-nginx
You'll need to set up port forwarding to access the services:
```bash
# Expose the UI locally
kubectl port-forward svc/keep-frontend 3000:3000 &

# Expose the Backend locally
kubectl port-forward svc/keep-backend 8080:8080 &

# Export websocket server (optional)
kubectl port-forward svc/keep-websocket 6001:6001 &
```

# Uninstallation
```bash
helm uninstall keep
```

# Configuration
To view supported configuration, see [this](charts/keep/README.md).

# Platform-Specific Instructions

## Openshift
Keep's Helm Chart supports installation on Openshift.
Configure the route settings under frontend(/backend).route:
```yaml
frontend:
  route:
    host: your-desired-hostname
```

## Local Kubernetes
For local Kubernetes clusters without external IP (such as when using NodePort or LoadBalancer):

1. If using ingress-nginx, ensure your ingress controller is properly configured for local development
2. If not using ingress-nginx, use the port forwarding method described in the "Without ingress-nginx" section

# Troubleshooting

## Common Issues
1. Ingress not working
   - Verify ingress-nginx is properly installed
   - Check if snippet annotations are enabled
   - Verify ingress configuration with `kubectl describe ingress`

2. WebSocket connection issues
   - Ensure the websocket service is running
   - Check ingress configuration for proper WebSocket headers
   - Verify connectivity using `curl` or browser developer tools

For more detailed configuration options and troubleshooting, refer to the [documentation](charts/keep/README.md).
