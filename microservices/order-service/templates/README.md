# Order Service Kubernetes Deployment

This folder contains Kubernetes manifests for deploying the Order Service.

## Files

- **deployment.yaml** - Kubernetes Deployment configuration
- **service.yaml** - Kubernetes Service (ClusterIP) for internal communication
- **configmap.yaml** - Configuration ConfigMap with environment variables
- **hpa.yaml** - Horizontal Pod Autoscaler for automatic scaling
- **kustomization.yaml** - Kustomize configuration for templating

## Prerequisites

- Kubernetes cluster (1.19+)
- kubectl configured to access your cluster
- `ecommerce-order-service:latest` Docker image pushed to your registry
- PostgreSQL service accessible at `postgres:5432`
- Product Service deployed and running
- ecommerce namespace created

## Deployment

### Using kubectl directly

```bash
# Create namespace
kubectl create namespace ecommerce

# Apply manifests
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f configmap.yaml
kubectl apply -f hpa.yaml
```

### Using Kustomize (Recommended)

```bash
# Create namespace
kubectl create namespace ecommerce

# Apply all manifests using kustomization
kubectl apply -k .
```

### Using Helm (if wrapped in Helm chart)

```bash
helm install order-service . -n ecommerce
```

## Verification

```bash
# Check deployment status
kubectl get deployment order-service -n ecommerce

# Check pods
kubectl get pods -n ecommerce -l app=order-service

# Check service
kubectl get service order-service -n ecommerce

# Check logs
kubectl logs -n ecommerce -l app=order-service -f

# Check HPA status
kubectl get hpa order-service-hpa -n ecommerce
```

## Configuration

### Customizing Replicas

Edit `kustomization.yaml`:
```yaml
replicas:
  - name: order-service
    count: 3  # Change this
```

### Customizing Image

Edit `kustomization.yaml`:
```yaml
images:
  - name: ecommerce-order-service
    newTag: v1.0.0  # Change tag
```

### Customizing Resource Limits

Edit `deployment.yaml`:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## Port Mapping

- **Service Port**: 8082
- **Container Port**: 8082
- **Service Type**: ClusterIP (internal only)

## Database Connection

- **Host**: postgres (service name in same namespace)
- **Port**: 5432
- **Database**: order_db
- **Username**: postgres (from secret)
- **Password**: postgres (from secret)

## Inter-Service Communication

- **Product Service URL**: http://product-service:8081
- This is configured in the ConfigMap as `PRODUCT_SERVICE_URL`

## Autoscaling

The HPA will automatically scale pods based on:
- CPU utilization > 70%
- Memory utilization > 80%

Min replicas: 2, Max replicas: 5

## Troubleshooting

### Pod not starting
```bash
kubectl describe pod <pod-name> -n ecommerce
kubectl logs <pod-name> -n ecommerce
```

### Service not accessible
```bash
kubectl get endpoints order-service -n ecommerce
```

### ConfigMap not mounted
```bash
kubectl get configmap order-service-config -n ecommerce
kubectl describe configmap order-service-config -n ecommerce
```

### Can't reach Product Service
```bash
# Test connectivity within cluster
kubectl exec -it <pod-name> -n ecommerce -- curl http://product-service:8081/api/products
```

## Cleanup

```bash
# Delete all resources
kubectl delete -k .

# Delete namespace
kubectl delete namespace ecommerce
```
