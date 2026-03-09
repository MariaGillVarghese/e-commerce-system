# Kubernetes Templates Summary

This document provides an overview of the Kubernetes deployment templates created for the E-Commerce microservices.

## Directory Structure Created

```
project-root/
├── k8s/                                           # Kubernetes configuration folder
│   ├── namespace.yaml                            # Creates ecommerce namespace
│   ├── postgres-secret.yaml                      # PostgreSQL credentials secret
│   ├── postgres-init-config.yaml                 # Database initialization script
│   ├── kustomization.yaml                        # Master Kustomize file for all services
│   └── README.md                                 # This file
│
├── product-service/templates/                    # Product Service Kubernetes manifests
│   ├── deployment.yaml                           # Deployment: 2 replicas, resource limits, health checks
│   ├── service.yaml                              # ClusterIP Service on port 8081
│   ├── configmap.yaml                            # Configuration for database connection
│   ├── hpa.yaml                                  # Horizontal Pod Autoscaler (2-5 replicas)
│   ├── kustomization.yaml                        # Kustomize configuration
│   └── README.md                                 # Deployment instructions
│
├── order-service/templates/                      # Order Service Kubernetes manifests
│   ├── deployment.yaml                           # Deployment: 2 replicas, resource limits, health checks
│   ├── service.yaml                              # ClusterIP Service on port 8082
│   ├── configmap.yaml                            # Configuration + Product Service URL
│   ├── hpa.yaml                                  # Horizontal Pod Autoscaler (2-5 replicas)
│   ├── kustomization.yaml                        # Kustomize configuration
│   └── README.md                                 # Deployment instructions
│
├── frontend-service/templates/                   # Frontend Service Kubernetes manifests
│   ├── deployment.yaml                           # Deployment: 2 replicas, resource limits, health checks
│   ├── service.yaml                              # NodePort Service on port 30080
│   ├── configmap.yaml                            # Configuration + backend service URLs
│   ├── hpa.yaml                                  # Horizontal Pod Autoscaler (2-5 replicas)
│   ├── kustomization.yaml                        # Kustomize configuration
│   └── README.md                                 # Deployment instructions
│
└── KUBERNETES.md                                 # Master Kubernetes deployment guide
```

## Files Created

### Namespace & Secrets (k8s/)
1. **namespace.yaml** (24 lines)
   - Creates `ecommerce` namespace for all services
   - Labeled for organization

2. **postgres-secret.yaml** (9 lines)
   - Stores PostgreSQL credentials securely
   - Username: postgres
   - Password: postgres (change in production!)

3. **postgres-init-config.yaml** (35 lines)
   - ConfigMap with database initialization SQL
   - Creates product_db and order_db
   - Initializes schemas and sample data

4. **kustomization.yaml** (41 lines)
   - Master Kustomize file
   - Combines all service deployments
   - Allows single deploy command for entire system

### Product Service Templates (product-service/templates/)
1. **deployment.yaml** (68 lines)
   - 2 replicas with rolling updates
   - Resource requests: 256Mi memory, 250m CPU
   - Resource limits: 512Mi memory, 500m CPU
   - Liveness probe: /actuator/health every 10s
   - Readiness probe: /actuator/health every 5s
   - Environment variables from ConfigMap and Secret

2. **service.yaml** (16 lines)
   - ClusterIP service (internal only)
   - Port 8081 mapped to container port 8081
   - Internal DNS: `product-service.ecommerce.svc.cluster.local`

3. **configmap.yaml** (14 lines)
   - Database URL: `jdbc:postgresql://postgres:5432/product_db`
   - Hibernate DDL: update
   - Logging configuration

4. **hpa.yaml** (31 lines)
   - Min replicas: 2, Max replicas: 5
   - Scale on CPU > 70% or Memory > 80%
   - Scale down stabilization: 300s
   - Scale up stabilization: 0s (immediate)

5. **kustomization.yaml** (24 lines)
   - Combines all manifests
   - Sets namespace and labels
   - Configures image tags
   - Sets replica count

6. **README.md** (200+ lines)
   - Detailed deployment instructions
   - Verification commands
   - Troubleshooting guide
   - Configuration customization examples

### Order Service Templates (order-service/templates/)
Similar to Product Service but:
1. **deployment.yaml** - Port 8082, Product Service URL environment variable
2. **service.yaml** - Port 8082
3. **configmap.yaml** - Contains `PRODUCT_SERVICE_URL=http://product-service:8081`
4. **hpa.yaml** - Same scaling policies
5. **kustomization.yaml** - Order service specific
6. **README.md** - Order service specific instructions

### Frontend Service Templates (frontend-service/templates/)
Similar structure but with differences:
1. **deployment.yaml** 
   - Port 8080 (Tomcat)
   - Higher resource limits (512Mi/1Gi)
   - Backend service URLs environment variables
   - Health check path: `/ecommerce/`

2. **service.yaml** 
   - NodePort type (external access)
   - NodePort: 30080
   - Access: `http://<node-ip>:30080/ecommerce`

3. **configmap.yaml** 
   - Contains both service URLs
   - Product Service: `http://product-service:8081`
   - Order Service: `http://order-service:8082`

4. **hpa.yaml** - Same scaling (2-5 replicas)

5. **kustomization.yaml** - Frontend service specific

6. **README.md** - Frontend service specific instructions

## Deployment Methods

### Quick Start - Deploy All Services
```bash
# From project root
kubectl apply -k k8s/
```

### Deploy Individual Services
```bash
# Product Service
kubectl apply -k product-service/templates/

# Order Service
kubectl apply -k order-service/templates/

# Frontend Service
kubectl apply -k frontend-service/templates/
```

### Deploy Step by Step
```bash
# 1. Create namespace
kubectl apply -f k8s/namespace.yaml

# 2. Create secrets
kubectl apply -f k8s/postgres-secret.yaml

# 3. Deploy each service
kubectl apply -k product-service/templates/
kubectl apply -k order-service/templates/
kubectl apply -k frontend-service/templates/
```

## Key Features

### High Availability
- ✅ 2-5 replicas per service (configurable)
- ✅ Horizontal Pod Autoscaler for each service
- ✅ Resource limits and requests
- ✅ Health checks (liveness & readiness probes)
- ✅ Rolling updates with zero downtime

### Security
- ✅ Secrets for sensitive data (passwords)
- ✅ ConfigMaps for configuration
- ✅ Namespace isolation
- ○ Network Policies (can be added)
- ○ Pod Security Policies (can be added)
- ○ RBAC (can be added)

### Service Communication
- ✅ ClusterIP services for internal communication
- ✅ NodePort for frontend external access
- ✅ Service discovery via DNS
- ✅ Environment variables for service URLs

### Configuration Management
- ✅ Kustomize for templating and overlays
- ✅ ConfigMaps for configuration
- ✅ Secrets for sensitive data
- ✅ Easy customization without file editing

### Monitoring & Logging
- ✅ Health checks configured
- ✅ Logging level configuration
- ✅ Resource metrics exposed
- ○ Prometheus integration (can be added)
- ○ Log aggregation (can be added)

## Environment Variables Reference

### Product Service
- `SPRING_DATASOURCE_URL`: jdbc:postgresql://postgres:5432/product_db
- `SPRING_DATASOURCE_USERNAME`: postgres (from Secret)
- `SPRING_DATASOURCE_PASSWORD`: postgres (from Secret)
- `SPRING_JPA_HIBERNATE_DDL_AUTO`: update
- `SPRING_JPA_DATABASE_PLATFORM`: org.hibernate.dialect.PostgreSQLDialect

### Order Service
- Same as Product Service plus:
- `PRODUCT_SERVICE_URL`: http://product-service:8081

### Frontend Service
- `PRODUCT_SERVICE_URL`: http://product-service:8081
- `ORDER_SERVICE_URL`: http://order-service:8082

## Service Ports

| Service | Container Port | Service Port | Type | Access |
|---------|---|---|---|---|
| Product | 8081 | 8081 | ClusterIP | Internal only |
| Order | 8082 | 8082 | ClusterIP | Internal only |
| Frontend | 8080 | 8080 | NodePort | External via :30080 |

## Database Configuration

- Database Host: `postgres` (service name, resolved via DNS)
- Database Port: 5432
- Product DB: `product_db`
- Order DB: `order_db`
- Credentials: Stored in postgres-secret.yaml

## Customization Examples

### Change Replica Count
Edit `k8s/kustomization.yaml`:
```yaml
replicas:
  - name: product-service
    count: 5
```

### Change Image Registry
Edit service's `kustomization.yaml`:
```yaml
images:
  - name: ecommerce-product-service
    newName: gcr.io/my-project/ecommerce-product-service
    newTag: v1.2.3
```

### Adjust Resource Limits
Edit service's `deployment.yaml`:
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

## Next Steps

1. **Build Docker Images**
   ```bash
   docker build -t ecommerce-product-service:latest ./product-service
   docker build -t ecommerce-order-service:latest ./order-service
   docker build -t ecommerce-frontend-service:latest ./frontend-service
   ```

2. **Push to Registry** (if using remote registry)
   ```bash
   docker tag ecommerce-product-service:latest <your-registry>/ecommerce-product-service:latest
   docker push <your-registry>/ecommerce-product-service:latest
   ```

3. **Deploy to Kubernetes**
   ```bash
   kubectl apply -k k8s/
   ```

4. **Verify**
   ```bash
   kubectl get all -n ecommerce
   ```

5. **Access Application**
   ```bash
   kubectl get svc frontend-service -n ecommerce -o wide
   # Access at http://<NODE-IP>:30080/ecommerce
   ```

## Important Notes

- ⚠️ Change PostgreSQL password in `postgres-secret.yaml` for production
- ⚠️ Update Docker image tags with version numbers instead of `latest`
- ⚠️ Configure proper storage for PostgreSQL persistence
- ⚠️ Add Network Policies for security
- ⚠️ Implement RBAC for access control
- ⚠️ Set resource limits appropriate for your cluster
- ⚠️ Configure proper logging and monitoring

## Support Files
- **KUBERNETES.md** - Complete Kubernetes deployment guide
- Each service's **README.md** - Service-specific instructions
