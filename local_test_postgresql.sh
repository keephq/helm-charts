#!/bin/bash

# Create a debug folder and values file
mkdir -p debug
cat <<EOF > debug/postgresql-values.yaml
global:
  ingress:
    enabled: true
    className: nginx
    websocketPrefix: /websocket
    backendPrefix: /v2
    frontendPrefix: /
frontend:
  enabled: true
backend:
  enabled: true
env:
  - name: DATABASE_CONNECTION_STRING
    value: "postgresql+psycopg2://postgres:mysecretpassword@keep-database:5432/keep"
  - name: DATABASE_NAME
    value: keep-database
  - name: SECRET_MANAGER_TYPE
    value: k8s
  - name: PORT
    value: "8080"
  - name: PUSHER_APP_ID
    value: 1
  - name: PUSHER_APP_KEY
    value: keepappkey
  - name: PUSHER_APP_SECRET
    value: keepappsecret
  - name: PUSHER_HOST
    value: keep-websocket
  - name: PUSHER_PORT
    value: "6001"
  - name: PROMETHEUS_MULTIPROC_DIR
    value: "/tmp/prometheus"
websocket:
  enabled: true
database:
  enabled: true
  type: postgres
  postgres:
    image:
      repository: postgres
      tag: "15.3"
    env:
      - name: POSTGRES_DB
        value: keep
      - name: POSTGRES_PASSWORD
        value: mysecretpassword
    port: 5432
    config:
      maxConnections: 100
      sharedBuffers: 128MB
  resources:
    requests:
      cpu: "500m"
      memory: "512Mi"
    limits:
      cpu: "1000m"
      memory: "1Gi"
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

# Install NGINX Ingress Controller
echo "📦 Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for NGINX ingress controller
echo "⏳ Waiting for NGINX ingress controller..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Install your chart
echo "📊 Installing Keep chart with PostgreSQL..."
helm install keep ./charts/keep -f debug/postgresql-values.yaml

# Wait for database to be ready
echo "⏳ Waiting for PostgreSQL database to be ready..."
kubectl wait --namespace default \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=keep,keep-component=database \
  --timeout=120s

# Wait for all Keep components to be ready
for component in frontend backend websocket; do
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

# Test PostgreSQL connection
echo -e "\n📊 Testing PostgreSQL connection..."
kubectl exec -it $(kubectl get pod -l keep-component=database -o jsonpath="{.items[0].metadata.name}") -- \
  psql -U postgres -d keep -c "\l"

# Show recent logs
echo -e "\n📜 Database logs:"
kubectl logs -l keep-component=database --tail=50

# Keep script running for debugging
echo -e "\n🔄 Debug session active. Press Ctrl+C to cleanup."
echo "📝 Quick commands:"
echo "  - kubectl get pods -A"
echo "  - kubectl describe ingress"
echo "  - kubectl logs <pod-name>"
echo "  - kubectl exec -it <database-pod> -- psql -U postgres -d keep"
echo "  - curl -v http://localhost/"
echo "  - curl -v http://localhost/v2/docs/"
echo "  - curl -v -H \"Upgrade: websocket\" -H \"Connection: Upgrade\" http://localhost/websocket/"

# Cleanup on exit
trap "kind delete cluster" EXIT
read -r -d '' _ </dev/tty 