# Keep Helm Chart
The Keep Helm Chart provides a convenient way to deploy and manage Keep on Kubernetes using Helm, a package manager for Kubernetes applications.

# Installation
The easiest way to install Keep with Helm is with the following command:

```bash
# add the Helm repository
helm repo add keephq https://keephq.github.io/helm-charts
# pull the latest version of the chart
helm pull keephq/keep
# install the chart
helm install keep keephq/keep
```

# Uninstallation
`helm uninstall keep`

# Configuration
To view supported configuration, see [this](charts/keep/README.md).

# Openshift
Keep's Helm Chart also supports installation on Openshift.
Simply set up the keys under frontend(/backend).route:
- route.host: your desired hostname

# Local Kubernetes
For local kubernetes without external IP (such as NodePort or LoadBalancer), you'll need to run port forwarding:

## Port forward
```bash

# expose the UI locally
kubectl port-forward svc/keep-frontend 3000:3000 & \
# export websocket server (optional)
kubectl port-forward svc/keep-websocket 6001:6001 &
```
