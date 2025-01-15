#!/bin/bash

# Create a debug folder and values file
mkdir -p debug
cat <<EOF > debug/nginx-values.yaml
global:
  ingress:
    enabled: true
    className: nginx
    classType: nginx
    websocketPrefix: /websocket
    backendPrefix: /v2
    frontendPrefix: /
frontend:
  enabled: true
backend:
  enabled: true
websocket:
  enabled: true
EOF

# Create Kind cluster with ingress ports exposed
cat <<EOF > debug/kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

# Function to check service/pod status
check_status() {
  echo "🔍 Checking all resources..."
  kubectl get pods -A
  kubectl get svc -A
  kubectl get ingress -A
}

# Create cluster
kind create cluster --config debug/kind-config.yaml

# Install Nginx Ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --set controller.service.type=NodePort \
  --set controller.watchIngressWithoutClass=true \
  --set controller.allowSnippetAnnotations=true \
  --set controller.config.allow-snippets=true \
  --set controller.config.enable-snippets=true \
  --set controller.config.annotations-risk-level=Critical \
  --set controller.hostPort.enabled=true \
  --set controller.service.ports.http=80 \
  --set controller.service.ports.https=443 \
  --set controller.nodeSelector."kubernetes\.io/os"=linux \
  --set controller.admissionWebhooks.enabled=false

# Wait for ingress controller
echo "⏳ Waiting for Nginx ingress controller..."
kubectl wait --namespace default \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=nginx-ingress \
  --timeout=90s

# Install your chart
helm install keep ./charts/keep -f debug/nginx-values.yaml

# Wait for pods
echo "⏳ Waiting for all pods to be ready..."
# Wait for backend pod (the last one to be ready)
echo "⏳ Waiting for Keep backend to be ready..."
kubectl wait --namespace default \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=keep,keep-component=backend \
  --timeout=120s

# Check status
check_status

# Test endpoints
echo "🧪 Testing endpoints..."

echo "Frontend (/) - Should redirect to /incidents:"
RESP=$(curl -s -I http://localhost/)
echo "$RESP" | grep "HTTP"
LOCATION=$(echo "$RESP" | grep -i "location")
echo "$LOCATION"
if [[ "$LOCATION" == *"/incidents"* ]]; then
  echo "✅ Redirect to /incidents confirmed"
else
  echo "❌ Redirect to /incidents not found"
  exit 1
fi

echo -e "\nBackend (/v2/docs) - Should return API info:"
RESP=$(curl -s http://localhost/v2/docs/)
echo "Response: $RESP"
if [[ $RESP == *"Rest API powering"* ]]; then
  echo "✅ Backend response contains expected message"
else
  echo "❌ Unexpected backend response"
fi

echo -e "\nWebSocket (/websocket) - Testing connection:"
wscat -c "ws://localhost/websocket/app/keepappkey?protocol=7&client=js&version=8.3.0&flash=false" &
WSCAT_PID=$!
sleep 2
kill $WSCAT_PID 2>/dev/null

# Show logs if needed
echo -e "\n📜 Ingress controller logs:"
kubectl logs -l app.kubernetes.io/instance=nginx-ingress --tail=100

# Keep script running for debugging
echo -e "\n🔄 Debug session active. Press Ctrl+C to cleanup."
echo "📝 Quick commands:"
echo "  - kubectl get pods -A"
echo "  - kubectl describe ingress"
echo "  - kubectl logs <pod-name>"
echo "  - curl -v http://localhost/"
echo "  - curl -v http://localhost/v2/docs/"
echo "  - curl -v -H \"Upgrade: websocket\" -H \"Connection: Upgrade\" http://localhost/websocket/"

# Wait for user interrupt
trap "kind delete cluster" EXIT
read -r -d '' _ </dev/tty