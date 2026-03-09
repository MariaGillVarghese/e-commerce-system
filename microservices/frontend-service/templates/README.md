# Frontend Service Kubernetes Deployment

This folder contains Kubernetes manifests for deploying the Frontend Service.

## Files

- **deployment.yaml** - Kubernetes Deployment configuration
- **service.yaml** - Kubernetes Service (NodePort) for external access
- **configmap.yaml** - Configuration ConfigMap with environment variables
- **hpa.yaml** - Horizontal Pod Autoscaler for automatic scaling
- **kustomization.yaml** - Kustomize configuration for templating

## Prerequisites

- Kubernetes cluster (1.19+)
- kubectl configured to access your cluster
- `ecommerce-frontend-service:latest` Docker image pushed to your registry
- Product Service deployed and running
- Order Service deployed and running
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
helm install frontend-service . -n ecommerce
```

## Verification

```bash
# Check deployment status
kubectl get deployment frontend-service -n ecommerce

# Check pods
kubectl get pods -n ecommerce -l app=frontend-service

# Check service
kubectl get service frontend-service -n ecommerce

# Get NodePort
kubectl get service frontend-service -n ecommerce -o jsonpath='{.spec.ports[0].nodePort}'

# Check logs
kubectl logs -n ecommerce -l app=frontend-service -f

# Check HPA status
kubectl get hpa frontend-service-hpa -n ecommerce
```

## Configuration

### Customizing Replicas

Edit `kustomization.yaml`:
```yaml
replicas:
  - name: frontend-service
    count: 3  # Change this
```

### Customizing Image

Edit `kustomization.yaml`:
```yaml
images:
  - name: ecommerce-frontend-service
    newTag: v1.0.0  # Change tag
```

### Customizing Resource Limits

Edit `deployment.yaml`:
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"
```

## Port Mapping

- **Service Port**: 8080
- **Container Port**: 8080
- **Service Type**: NodePort
- **NodePort**: 30080 (access at http://node-ip:30080/ecommerce)

## Accessing the Application

### From Kubernetes cluster
```
http://frontend-service:8080/ecommerce
```

### From outside the cluster
```
http://<node-ip>:30080/ecommerce
```

Where `<node-ip>` is the IP address of any Kubernetes node.

## Inter-Service Communication

- **Product Service URL**: http://product-service:8081
- **Order Service URL**: http://order-service:8082
- These are configured in the ConfigMap

## Autoscaling

The HPA will automatically scale pods based on:
- CPU utilization > 75%
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
kubectl get endpoints frontend-service -n ecommerce
```

### ConfigMap not mounted
```bash
kubectl get configmap frontend-service-config -n ecommerce
kubectl describe configmap frontend-service-config -n ecommerce
```

### Can't reach backend services
```bash
# Test connectivity within cluster
kubectl exec -it <pod-name> -n ecommerce -- curl http://product-service:8081/api/products
kubectl exec -it <pod-name> -n ecommerce -- curl http://order-service:8082/api/orders
```

## Changing NodePort

Edit `service.yaml`:
```yaml
ports:
  - name: http
    port: 8080
    targetPort: 8080
    nodePort: 30080  # Change this to desired port (30000-32767)
```

## Using Ingress (Alternative to NodePort)

Instead of NodePort, you can use an Ingress for better routing:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  namespace: ecommerce
spec:
  ingressClassName: nginx
  rules:
  - host: ecommerce.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 8080
```

## Cleanup

```bash
# Delete all resources
kubectl delete -k .

# Delete namespace
kubectl delete namespace ecommerce
```
