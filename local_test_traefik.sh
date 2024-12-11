#!/bin/bash

# Create a debug folder and values file
mkdir -p debug
cat <<EOF > debug/traefik-values.yaml
global:
  ingress:
    enabled: true
    className: traefik
    classType: traefik
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
  - containerPort: 30080
    hostPort: 30080
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

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check required tools
for tool in kind kubectl helm wscat curl; do
  if ! command_exists "$tool"; then
    echo "❌ Required tool not found: $tool"
    exit 1
  fi
done

# Create cluster
echo "🚀 Creating Kind cluster..."
kind create cluster --config debug/kind-config.yaml

# Install Traefik
echo "📦 Adding Traefik helm repo..."
helm repo add traefik https://traefik.github.io/charts
helm repo update

echo "🔧 Installing Traefik..."
helm install traefik traefik/traefik \
  --set installCRDs=true \
  --set ports.web.port=8000 \
  --set ports.web.exposedPort=80 \
  --set ports.web.nodePort=30080 \
  --set service.type=NodePort \
  --set ingressClass.enabled=true \
  --set ingressClass.isDefaultClass=true

# Wait for Traefik controller
echo "⏳ Waiting for Traefik controller..."
kubectl wait --namespace default \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=traefik \
  --timeout=90s

# Create middleware for path stripping
echo "🔧 Creating Traefik middleware..."
echo "⏳ Waiting for Traefik CRDs to be available..."
kubectl wait --for condition=established --timeout=60s crd/middlewares.traefik.io

# Install your chart
echo "📊 Installing Keep chart..."
helm install keep ./charts/keep -f debug/traefik-values.yaml

# Wait for all Keep components to be ready
for component in frontend backend websocket database; do
  echo "⏳ Waiting for Keep $component to be ready..."
  kubectl wait --namespace default \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/instance=keep,keep-component=$component \
    --timeout=120s
done

# Check status
check_status

# Function to test endpoint with retry
test_endpoint() {
  local url=$1
  local expected=$2
  local max_attempts=5
  local attempt=1
  
  while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt of $max_attempts..."
    RESP=$(curl -s "$url")
    if [[ $RESP == *"$expected"* ]]; then
      echo "✅ Response contains expected content"
      return 0
    fi
    echo "⏳ Waiting before retry..."
    sleep 5
    ((attempt++))
  done
  echo "❌ Failed to get expected response after $max_attempts attempts"
  return 1
}

# Test endpoints
echo "🧪 Testing endpoints..."

echo -e "\nFrontend (/) - Testing redirect:"
RESP=$(curl -s -I http://localhost/)
echo "$RESP" | grep "HTTP"
LOCATION=$(echo "$RESP" | grep -i "location")
echo "$LOCATION"

echo -e "\nBackend (/v2/docs) - Testing API docs:"
test_endpoint "http://localhost/v2/docs" "Rest API powering"

echo -e "\nWebSocket (/websocket) - Testing connection:"
timeout 5 wscat -c "ws://localhost/websocket/app/keepappkey?protocol=7&client=js&version=8.3.0&flash=false" || true

# Show Traefik dashboard
echo -e "\n📊 Traefik Dashboard available at: http://localhost:8080/dashboard/"

# Show recent logs
echo -e "\n📜 Traefik controller logs:"
kubectl logs -l app.kubernetes.io/name=traefik --tail=50

# Keep script running for debugging
echo -e "\n🔄 Debug session active. Press Ctrl+C to cleanup."
echo "📝 Quick commands:"
echo "  - kubectl get pods -A"
echo "  - kubectl describe ingress"
echo "  - kubectl logs <pod-name>"
echo "  - kubectl port-forward svc/traefik 8080:8080"
echo "  - curl -v http://localhost/"
echo "  - curl -v http://localhost/v2/docs/"
echo "  - curl -v -H \"Upgrade: websocket\" -H \"Connection: Upgrade\" http://localhost/websocket/"

# Cleanup on exit
trap "kind delete cluster" EXIT
read -r -d '' _ </dev/tty