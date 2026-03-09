# Kubernetes Deployment Guide

This guide explains how to deploy the E-Commerce microservices on Kubernetes.

## Directory Structure

```
k8s/
├── namespace.yaml              # Kubernetes namespace
├── postgres-secret.yaml        # Database credentials secret
├── postgres-init-config.yaml   # Database initialization
├── kustomization.yaml          # Master Kustomize file

product-service/templates/
├── deployment.yaml             # Deployment configuration
├── service.yaml                # ClusterIP Service
├── configmap.yaml              # Configuration
├── hpa.yaml                    # Horizontal Pod Autoscaler
├── kustomization.yaml          # Kustomize configuration
└── README.md                   # Service-specific deployment guide

order-service/templates/
├── deployment.yaml
├── service.yaml
├── configmap.yaml
├── hpa.yaml
├── kustomization.yaml
└── README.md

frontend-service/templates/
├── deployment.yaml
├── service.yaml
├── configmap.yaml
├── hpa.yaml
├── kustomization.yaml
└── README.md
```

## Prerequisites

- Kubernetes cluster 1.19+ (minikube, k3s, EKS, GKE, AKS, etc.)
- kubectl CLI configured to access your cluster
- Minimum cluster resources:
  - 4 CPU cores
  - 4GB RAM
- PostgreSQL running (in-cluster or external)
- Docker images built and available:
  - ecommerce-product-service:latest
  - ecommerce-order-service:latest
  - ecommerce-frontend-service:latest

## Deployment Steps

### Step 1: Prepare Your Kubernetes Cluster

```bash
# Verify cluster connection
kubectl cluster-info
kubectl get nodes

# Create namespace
kubectl apply -f k8s/namespace.yaml

# Create secrets for PostgreSQL
kubectl apply -f k8s/postgres-secret.yaml
```

### Step 2: Deploy Services Independently

Each service has its own templates folder for independent deployment:

#### Deploy Product Service
```bash
kubectl apply -k product-service/templates/
```

#### Deploy Order Service
```bash
kubectl apply -k order-service/templates/
```

#### Deploy Frontend Service
```bash
kubectl apply -k frontend-service/templates/
```

### Step 3: (Alternative) Deploy All Services at Once

Create a root kustomization.yaml to deploy all services together:

```bash
kubectl apply -k .
```

### Step 4: Verify Deployments

```bash
# Check all resources
kubectl get all -n ecommerce

# Check deployment status
kubectl get deployments -n ecommerce

# Check pods
kubectl get pods -n ecommerce

# Check services
kubectl get services -n ecommerce

# Check HPA
kubectl get hpa -n ecommerce
```

### Step 5: Access the Application

Get the NodePort for frontend service:
```bash
kubectl get svc frontend-service -n ecommerce -o jsonpath='{.spec.ports[0].nodePort}'
```

Access at:
```
http://<node-ip>:30080/ecommerce
```

Get node IP:
```bash
kubectl get nodes -o wide
```

## Deployment Methods

### 1. Using Kustomize (Recommended)

```bash
# Deploy single service
kubectl apply -k product-service/templates/

# Deploy all services
kubectl apply -k .
```

**Advantages:**
- No template processing needed
- Easy customization
- Native Kubernetes support
- Combines multiple manifests

### 2. Using kubectl directly

```bash
# Deploy product service
kubectl apply -f product-service/templates/deployment.yaml
kubectl apply -f product-service/templates/service.yaml
kubectl apply -f product-service/templates/configmap.yaml
kubectl apply -f product-service/templates/hpa.yaml
```

### 3. Using Helm (if creating charts)

```bash
helm repo add ecommerce ./helm
helm install ecommerce ecommerce/ecommerce -n ecommerce
```

### 4. Using ArgoCD (GitOps)

Create ArgoCD Application:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ecommerce
spec:
  project: default
  source:
    repoURL: https://github.com/your-repo
    targetRevision: main
    path: ./
  destination:
    server: https://kubernetes.default.svc
    namespace: ecommerce
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Configuration Management

### Environment Variables

Each service's environment variables can be modified in:
- `configmap.yaml` - For non-sensitive config
- `postgres-secret.yaml` - For sensitive data

### Modifying Replicas

Edit service's `kustomization.yaml`:
```yaml
replicas:
  - name: product-service
    count: 3
```

### Customizing Image Registry

Edit service's `kustomization.yaml`:
```yaml
images:
  - name: ecommerce-product-service
    newName: your-registry/ecommerce-product-service
    newTag: v1.0.0
```

### Resource Limits

Edit `deployment.yaml` in each service:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## Verification Commands

```bash
# Check deployment replicas
kubectl get deployment -n ecommerce -w

# Check pod status
kubectl get pods -n ecommerce -o wide

# Check logs
kubectl logs -n ecommerce -l app=product-service -f
kubectl logs -n ecommerce -l app=order-service -f
kubectl logs -n ecommerce -l app=frontend-service -f

# Check service endpoints
kubectl get endpoints -n ecommerce

# Check HPA status
kubectl get hpa -n ecommerce -w

# Describe pod for debugging
kubectl describe pod <pod-name> -n ecommerce

# Access logs of specific pod
kubectl logs <pod-name> -n ecommerce --tail=100 -f

# Execute command in pod
kubectl exec -it <pod-name> -n ecommerce -- /bin/bash
```

## API Testing

### Port Forwarding (for testing)

```bash
# Product Service
kubectl port-forward svc/product-service 8081:8081 -n ecommerce

# Order Service
kubectl port-forward svc/order-service 8082:8082 -n ecommerce

# Frontend Service
kubectl port-forward svc/frontend-service 8080:8080 -n ecommerce
```

Then access:
- Product API: http://localhost:8081/api/products
- Order API: http://localhost:8082/api/orders
- Frontend: http://localhost:8080/ecommerce

### Testing from within cluster

```bash
# Get a pod shell
kubectl run -it --image=alpine:3.15 shell -- sh

# Inside pod, test connectivity
wget -O- http://product-service:8081/api/products
wget -O- http://order-service:8082/api/orders
wget -O- http://frontend-service:8080/ecommerce
```

## Scaling

### Manual Scaling

```bash
# Scale product service to 5 replicas
kubectl scale deployment product-service -n ecommerce --replicas=5

# Check scaling
kubectl get deployment product-service -n ecommerce
```

### Automatic Scaling (already configured)

HPA is configured in each service. Monitor:
```bash
kubectl get hpa -n ecommerce -w
```

## Updating Services

### Rolling Update

```bash
# Update image
kubectl set image deployment/product-service \
  product-service=ecommerce-product-service:v2.0.0 \
  -n ecommerce

# Check rollout status
kubectl rollout status deployment/product-service -n ecommerce
```

### Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/product-service -n ecommerce

# Rollback to specific revision
kubectl rollout undo deployment/product-service --to-revision=2 -n ecommerce

# Check rollout history
kubectl rollout history deployment/product-service -n ecommerce
```

## Monitoring and Logging

### View metrics (requires metrics-server)

```bash
# Install metrics-server (if not present)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# View pod metrics
kubectl top pods -n ecommerce

# View node metrics
kubectl top nodes
```

### Persistent Logs

For production, integrate with:
- Elasticsearch + Fluentd + Kibana (EFK)
- Splunk
- Datadog
- CloudWatch (for AWS EKS)

## Cleanup

```bash
# Delete all services (one by one)
kubectl delete -k product-service/templates/
kubectl delete -k order-service/templates/
kubectl delete -k frontend-service/templates/

# Delete secrets and config
kubectl delete -f k8s/postgres-secret.yaml
kubectl delete -f k8s/postgres-init-config.yaml

# Delete namespace (removes everything)
kubectl delete namespace ecommerce
```

## Production Considerations

### High Availability
- ✅ Multiple replicas configured (min: 2, max: 5)
- ✅ HPA configured for automatic scaling
- ✅ Health checks implemented
- Consider: Pod disruption budgets, affinity rules

### Security
- ✅ Secrets for database credentials
- Add: RBAC policies, Network policies, Pod security policies
- Add: TLS/HTTPS for services

### Monitoring
- Add: Prometheus metrics collection
- Add: Grafana dashboards
- Add: Alert rules

### Backup & Recovery
- Add: Regular PostgreSQL backups
- Add: Automated database snapshot policies
- Add: Disaster recovery plan

### Networking
- Consider: Service mesh (Istio, Linkerd)
- Consider: Ingress controller (Nginx, Traefik)
- Add: Network policies for pod-to-pod communication

### Resource Management
- Review resource requests/limits
- Implement resource quotas per namespace
- Use quality of service (QoS) classes

## Troubleshooting

### Pods not starting

```bash
kubectl describe pod <pod-name> -n ecommerce
kubectl logs <pod-name> -n ecommerce
```

### Services not communicating

```bash
# Check DNS
kubectl run -it --image=alpine:3.15 shell -- nslookup product-service.ecommerce

# Check network policy
kubectl get networkpolicy -n ecommerce
```

### Out of resources

```bash
kubectl top nodes
kubectl describe nodes
# Scale down HPA or reduce replicas
```

### Image pull errors

```bash
# Verify image exists and is accessible
docker image ls
# Check image pull secrets
kubectl get secrets -n ecommerce
```

## Further Reading

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kustomize Guide](https://kustomize.io/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Security Best Practices](https://kubernetes.io/docs/concepts/security/)
