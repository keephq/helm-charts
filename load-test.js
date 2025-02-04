import http from "k6/http";
import { check, sleep } from "k6";
import { uuidv4 } from "https://jslib.k6.io/k6-utils/1.4.0/index.js";
import { Counter } from "k6/metrics";

// Define custom metrics for status codes
const errorCounter = new Counter('error_types');
const statusCodes = {
  0: new Counter('connection_errors'),  // Special case for connection errors
  200: new Counter('status_200'),
  202: new Counter('status_202'), 
  400: new Counter('status_400'),
  401: new Counter('status_401'),
  403: new Counter('status_403'),
  404: new Counter('status_404'),
  429: new Counter('status_429'),
  500: new Counter('status_500'),
  502: new Counter('status_502'),
  503: new Counter('status_503'),
  504: new Counter('status_504'),
};

// Test configuration
// Keep your original test configuration
export const options = {
  scenarios: {
    spike: {
      executor: 'shared-iterations',
      vus: 4000,
      iterations: 4000,
      maxDuration: '5s'
    }
  },
  // Connection handling
  batch: 50,               // Increased batch size for spike
  noConnectionReuse: false, // Don't reuse connections for more realistic spike
  noVUConnectionReuse: true,
  throw: false,            // Don't throw on failed requests
  // Timeouts and other settings
  timeout: '60s',          // Longer timeout for spike
  insecureSkipTLSVerify: true,
};

// Test setup
// const API_ENDPOINT = "http://localhost/v2/alerts/event/grafana";
const API_ENDPOINT = "http://localhost:8080/alerts/event/grafana";
const API_KEY = "710e72e4-f19f-45fb-b400-be5a1d02df3a";

const headers = {
  "Content-Type": "application/json",
  Accept: "application/json",
  "X-API-KEY": API_KEY,
};

const getRandomAnnotation = () => {
  const annotations = [
    {
      summary:
        "The pod 'api-service-production' lacks memory causing high error rate",
      description:
        "Due to the lack of memory, the pod 'api-service-production' is experiencing high error rate",
    },
    {
      summary: "High CPU utilization detected in production cluster",
      description:
        "CPU usage has exceeded 85% threshold in the production environment",
    },
    {
      summary: "Database connection pool exhausted",
      description:
        "The number of active database connections has reached maximum capacity",
    },
    {
      summary: "Network latency spike detected",
      description: "Unusual network latency detected in the us-east-1 region",
    },
    {
      summary: "Disk usage warning on primary storage",
      description:
        "Storage utilization has exceeded 80% on primary disk volume",
    },
    {
      summary: "API response time degradation",
      description:
        "Average API response time has increased beyond acceptable threshold",
    },
    {
      summary: "Cache hit ratio dropped below threshold",
      description:
        "Redis cache hit ratio has dropped below 60% in the last 5 minutes",
    },
    {
      summary: "Queue processing delay detected",
      description:
        "Message processing in main queue is experiencing unusual delays",
    },
    {
      summary: "High error rate in authentication service",
      description:
        "Authentication service is experiencing elevated error rates",
    },
    {
      summary: "Load balancer health check failures",
      description: "Multiple instances failing load balancer health checks",
    },
    {
      summary: "Kubernetes pod restart detected",
      description: "Multiple pod restarts observed in the production namespace",
    },
  ];

  return annotations[Math.floor(Math.random() * annotations.length)];
};

const createAlert = () => {
  return {
    labels: {
      severity: "critical",
      pod: "api-service-production",
      region: "us-east-1",
      cpu: Math.floor(Math.random() * 100).toString(),
      memory: Math.floor(Math.random() * 1000) + "Mi",
    },
    annotations: getRandomAnnotation(),
    state: "alerting",
    activeAt: new Date().toISOString(),
    value: Math.floor(Math.random() * 100),
    metric: "memory_usage",
    evalMatches: [
      {
        value: Math.floor(Math.random() * 100),
        metric: "memory_usage",
        tags: {
          pod: "api-service-production",
          region: "us-east-1",
        },
      },
    ],
    fingerprint: uuidv4().toString(),
  };
};

// Generate payload with 10 alerts
const generatePayload = () => {
  const alerts = Array.from({ length: 10 }, () => createAlert());

  return {
    alerts: alerts,
    status: "firing",
    title: "Memory Alert",
    severity: "critical",
  };
};

// Use generatePayload() instead of the single alert payload
const payload = generatePayload();

export default function () {
  try {
    const response = http.post(API_ENDPOINT, JSON.stringify(payload), {
      headers,
      timeout: '30s',
    });
    
    // Track the status code
    if (statusCodes[response.status]) {
      statusCodes[response.status].add(1);
      console.log(`Received status code: ${response.status}`);
    }

  } catch (error) {
    if (error.response && statusCodes[error.response.status]) {
      statusCodes[error.response.status].add(1);
      console.log(`Error with status code: ${error.response.status}`);
    } else {
      statusCodes[0].add(1);
      errorCounter.add(1, { error: error.message });
      console.log(`Connection error: ${error.message}`);
    }
  }
}

export function handleSummary(data) {
  console.log("\n========== Test Summary ==========");
  
  // Print Status Code Distribution
  console.log("\nStatus Code Distribution:");
  
  
  // Print General Statistics
  console.log("\nGeneral Statistics:");
  console.log(`Total Requests Attempted: ${data.metrics.http_reqs.values.count}`);
  
  // Status code breakdown
  if (data.metrics.status_202) {
    console.log(`202 Responses: ${data.metrics.status_202.values.count}`);
  }
  if (data.metrics.status_429) {
    console.log(`429 Responses: ${data.metrics.status_429.values.count}`);
  }
  if (data.metrics.status_502) {
    console.log(`502 Responses: ${data.metrics.status_502.values.count}`);
  }
  if (data.metrics.connection_errors) {
    console.log(`Connection Errors: ${data.metrics.connection_errors.values.count}`);
  }
  
  // Response time statistics
  if (data.metrics.http_req_duration) {
    console.log("\nResponse Time Statistics:");
    console.log(`Median: ${(data.metrics.http_req_duration.values.med / 1000).toFixed(2)}s`);
    console.log(`95th percentile: ${(data.metrics.http_req_duration.values.p95 / 1000).toFixed(2)}s`);
    console.log(`Max: ${(data.metrics.http_req_duration.values.max / 1000).toFixed(2)}s`);
  }

  console.log("\n=================================");
  
  return {};
}