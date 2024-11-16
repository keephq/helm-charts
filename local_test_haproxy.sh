#!/bin/bash

# Create a debug folder and values file
mkdir -p debug
cat <<EOF > debug/haproxy-values.yaml
global:
  ingress:
    enabled: true
    className: haproxy
    annotations:
      ingress.class: haproxy
    websocketPrefix: /websocket
    backendPrefix: /v2/docs
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
  - containerPort: 30024
    hostPort: 30024
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

# Add and update HAProxy helm repo
echo "📦 Adding HAProxy helm repo..."
helm repo add haproxytech https://haproxy-ingress.github.io/charts
helm repo update

# Install HAProxy Ingress Controller
echo "🔧 Installing HAProxy Ingress Controller..."
helm install haproxy haproxy-ingress/haproxy-ingress \
  --set controller.service.type=NodePort \
  --set controller.kind=DaemonSet \
  --set controller.daemonset.useHostPort=true \
  --set controller.service.ports.http=80 \
  --set controller.service.ports.https=443 \
  --set controller.service.ports.stat=30024

# Wait for HAProxy ingress controller
echo "⏳ Waiting for HAProxy ingress controller..."
kubectl wait --namespace default \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=haproxy \
  --timeout=90s

# Install your chart
echo "📊 Installing Keep chart..."
helm install keep ./charts/keep -f debug/haproxy-values.yaml

# Wait for backend pod (the last one to be ready)
echo "⏳ Waiting for Keep backend to be ready..."
kubectl wait --namespace default \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=keep,keep-component=backend \
  --timeout=90s

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

# Show HAProxy stats
echo -e "\n📊 HAProxy Stats:"
curl -s "http://localhost:30024/stats?stats;csv"

# Show logs if needed
echo -e "\n📜 HAProxy controller logs:"
kubectl logs -l app.kubernetes.io/instance=haproxy --tail=100

# Keep script running for debugging
echo -e "\n🔄 Debug session active. Press Ctrl+C to cleanup."
echo "📝 Quick commands:"
echo "  - kubectl get pods -A"
echo "  - kubectl describe ingress"
echo "  - kubectl logs <pod-name>"
echo "  - curl -v http://localhost/"
echo "  - curl -v http://localhost/v2/docs/"
echo "  - curl -v -H \"Upgrade: websocket\" -H \"Connection: Upgrade\" http://localhost/websocket/"
echo "  - curl http://localhost:30024/stats"

# Wait for user interrupt
trap "kind delete cluster" EXIT
read -r -d '' _ </dev/tty