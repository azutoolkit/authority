# Kubernetes Deployment

Deploy Authority on Kubernetes for scalable, production-ready authentication.

## Prerequisites

- Kubernetes cluster (1.24+)
- kubectl configured
- Helm 3 (optional)

## Quick Start with Manifests

### 1. Create Namespace

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: authority
```

```bash
kubectl apply -f namespace.yaml
```

### 2. Create Secrets

```bash
# Generate secret key
kubectl create secret generic authority-secrets \
  --namespace authority \
  --from-literal=secret-key=$(openssl rand -hex 32) \
  --from-literal=db-password=$(openssl rand -hex 16)
```

### 3. Deploy PostgreSQL

```yaml
# postgres.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: authority
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_USER
          value: authority
        - name: POSTGRES_DB
          value: authority_db
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: authority-secrets
              key: db-password
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        livenessProbe:
          exec:
            command: ["pg_isready", "-U", "authority"]
          initialDelaySeconds: 30
          periodSeconds: 10
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: authority
spec:
  ports:
  - port: 5432
  selector:
    app: postgres
  clusterIP: None
```

### 4. Deploy Authority

```yaml
# authority.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: authority
  namespace: authority
spec:
  replicas: 3
  selector:
    matchLabels:
      app: authority
  template:
    metadata:
      labels:
        app: authority
    spec:
      containers:
      - name: authority
        image: azutoolkit/authority:latest
        ports:
        - containerPort: 4000
        env:
        - name: CRYSTAL_ENV
          value: production
        - name: PORT
          value: "4000"
        - name: BASE_URL
          value: "https://auth.example.com"
        - name: SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: authority-secrets
              key: secret-key
        - name: DATABASE_URL
          value: "postgres://authority:$(DB_PASSWORD)@postgres:5432/authority_db"
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: authority-secrets
              key: db-password
        livenessProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 5
          periodSeconds: 10
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: authority
  namespace: authority
spec:
  ports:
  - port: 80
    targetPort: 4000
  selector:
    app: authority
```

### 5. Configure Ingress

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: authority
  namespace: authority
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - auth.example.com
    secretName: authority-tls
  rules:
  - host: auth.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: authority
            port:
              number: 80
```

### 6. Apply All Manifests

```bash
kubectl apply -f namespace.yaml
kubectl apply -f postgres.yaml
kubectl apply -f authority.yaml
kubectl apply -f ingress.yaml
```

## Helm Chart

### Add Repository

```bash
helm repo add authority https://azutoolkit.github.io/authority-helm
helm repo update
```

### Install

```bash
helm install authority authority/authority \
  --namespace authority \
  --create-namespace \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=auth.example.com \
  --set postgresql.enabled=true
```

### Custom Values

Create `values.yaml`:

```yaml
replicaCount: 3

image:
  repository: azutoolkit/authority
  tag: latest

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: auth.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: authority-tls
      hosts:
        - auth.example.com

postgresql:
  enabled: true
  auth:
    database: authority_db
    username: authority
  primary:
    persistence:
      size: 10Gi

redis:
  enabled: true

resources:
  requests:
    memory: 256Mi
    cpu: 100m
  limits:
    memory: 512Mi
    cpu: 500m

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

Install with values:

```bash
helm install authority authority/authority \
  --namespace authority \
  --create-namespace \
  -f values.yaml
```

## High Availability

### Database

Use a managed PostgreSQL service (RDS, Cloud SQL) or deploy a PostgreSQL cluster:

```yaml
postgresql:
  enabled: false

externalDatabase:
  host: your-postgres.xxx.rds.amazonaws.com
  port: 5432
  database: authority_db
  username: authority
  existingSecret: authority-db-secret
```

### Redis for Sessions

```yaml
redis:
  enabled: true
  architecture: replication
  replica:
    replicaCount: 2
```

### Pod Disruption Budget

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: authority-pdb
  namespace: authority
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: authority
```

## Monitoring

### ServiceMonitor (Prometheus)

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: authority
  namespace: authority
spec:
  selector:
    matchLabels:
      app: authority
  endpoints:
  - port: http
    path: /metrics
```

### Logs

View logs:

```bash
kubectl logs -f -l app=authority -n authority
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n authority
kubectl describe pod authority-xxx -n authority
```

### Database Connection Issues

```bash
kubectl exec -it authority-xxx -n authority -- sh
curl postgres:5432
```

### View Events

```bash
kubectl get events -n authority --sort-by='.lastTimestamp'
```

## Next Steps

- [Environment Variables](../configuration/environment-variables.md) - Configuration options
- [SSL Certificates](../configuration/ssl-certificates.md) - TLS configuration
- [Enable MFA](../security/enable-mfa.md) - Multi-factor authentication
