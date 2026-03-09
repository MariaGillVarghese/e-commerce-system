# E-Commerce Microservices System

A production-ready microservices architecture built with Spring Boot 2.7.14, PostgreSQL, Docker, and Kubernetes.

## 📋 Overview

This project demonstrates a complete microservices architecture with three independent services:
- **Product Service** (Port 8081) - Product catalog management
- **Order Service** (Port 8082) - Order processing and fulfillment
- **Frontend Service** (Port 8080) - Web UI with JSP templates

### Key Features

✅ **Microservices Architecture** - Loosely coupled, independently deployable services  
✅ **Multi-Level Deployment** - Local, Docker, Kubernetes support  
✅ **Secure Credentials** - Jasypt encryption + environment variable override  
✅ **Database Persistence** - PostgreSQL with schema management  
✅ **API Integration** - RESTful inter-service communication  
✅ **Auto-Scaling** - Horizontal Pod Autoscaler for Kubernetes  
✅ **Health Checks** - Liveness and readiness probes  
✅ **Configuration Management** - Externalized configuration via ConfigMap and Secrets  
✅ **Infrastructure as Code** - Docker Compose and Kubernetes YAML templates  

## 🚀 Quick Start

### 1. Local Development (No Database)

Uses in-memory H2 database:
```bash
# Build all services
mvn -s settings.xml clean package -DskipTests

# Run services in separate terminals
java -jar product-service/target/product-service-1.0.0.jar
java -jar order-service/target/order-service-1.0.0.jar
java -jar frontend-service/target/frontend-service-1.0.0.war
```

Access: http://localhost:8080/ecommerce

### 2. Docker Compose (Recommended)

```bash
docker-compose up -d
```

Access: http://localhost:8080/ecommerce

### 3. Kubernetes (Production)

```bash
kubectl apply -k k8s/
```

## 🔐 Property Override & Credentials Management

### Option 1: Environment Variables (Easiest)

```bash
export SPRING_DATASOURCE_USERNAME="prod_user"
export SPRING_DATASOURCE_PASSWORD="SecurePassword123!"
java -jar product-service-1.0.0.jar
```

### Option 2: Command Line Arguments

```bash
java -jar product-service-1.0.0.jar \
  --spring.datasource.username=prod_user \
  --spring.datasource.password=SecurePassword123!
```

### Option 3: Jasypt Encryption (Recommended for Production)

```bash
# Generate encryption key
openssl rand -base64 32

# Encrypt credentials
jasypt encrypt input=postgres password=your_key

# Use encrypted values in properties
spring.datasource.password=ENC(encrypted_value)

# Provide key at startup
export JASYPT_ENCRYPTOR_PASSWORD=your_key
java -jar product-service-1.0.0.jar
```

### Option 4: Docker Compose

```yaml
environment:
  SPRING_DATASOURCE_USERNAME: prod_user
  SPRING_DATASOURCE_PASSWORD: SecurePassword123!
```

### Option 5: Kubernetes Secrets

```bash
kubectl create secret generic postgres-credentials \
  --from-literal=username=prod_user \
  --from-literal=password=SecurePassword123! \
  -n ecommerce
```

**See detailed guides:**
- [PROPERTIES_OVERRIDE_GUIDE.md](PROPERTIES_OVERRIDE_GUIDE.md) - All property override methods
- [CREDENTIALS_MANAGEMENT.md](CREDENTIALS_MANAGEMENT.md) - Secure credential encryption

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [DOCKER.md](DOCKER.md) | Docker & Docker Compose deployment |
| [KUBERNETES.md](KUBERNETES.md) | Kubernetes deployment with manifests |
| [PROPERTIES_OVERRIDE_GUIDE.md](PROPERTIES_OVERRIDE_GUIDE.md) | 5 ways to override properties |
| [CREDENTIALS_MANAGEMENT.md](CREDENTIALS_MANAGEMENT.md) | Jasypt encryption & key management |

## 📖 API Endpoints

### Product Service (Port 8081)
```
GET    /api/products              # List all products
GET    /api/products/{id}         # Get product by ID  
POST   /api/products              # Create new product
```

### Order Service (Port 8082)
```
GET    /api/orders                # List all orders
GET    /api/orders/{id}           # Get order by ID
POST   /api/orders                # Create new order
```

### Frontend Service (Port 8080)
```
GET    /ecommerce/                # Home page
GET    /ecommerce/products        # Product list
GET    /ecommerce/orders          # Order list
```

## 🛠️ Technology Stack

- **Framework**: Spring Boot 2.7.14
- **Java**: OpenJDK 1.8
- **Build**: Maven 3.6+
- **Database**: PostgreSQL 13+
- **Container**: Docker 20.10+
- **Orchestration**: Kubernetes 1.19+
- **Security**: Jasypt 3.0.5

## 📊 Available Commands

### Build
```bash
mvn -s settings.xml clean package -DskipTests
```

### Local Run
```bash
java -jar product-service/target/product-service-1.0.0.jar
java -jar order-service/target/order-service-1.0.0.jar
java -jar frontend-service/target/frontend-service-1.0.0.war
```

### Docker Compose
```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f service-name
```

### Kubernetes
```bash
# Deploy
kubectl apply -k k8s/

# Status
kubectl get all -n ecommerce

# Logs
kubectl logs -f -l app=product-service -n ecommerce

# Cleanup
kubectl delete namespace ecommerce
```

## 🔒 Security

✅ **Implemented:**
- Environment variable secrets
- Jasypt encryption ready
- Kubernetes Secrets integration
- Health checks
- Resource limits

⚠️ **Recommended for Production:**
- Enable TLS/HTTPS
- RBAC in Kubernetes
- Network Policies
- Secret encryption at rest
- Log aggregation

## 📁 Project Structure Key Files

```
├── pom.xml                          # Parent POM with Jasypt dependency
├── settings.xml                     # Maven configuration
├── docker-compose.yml               # Docker Compose orchestration
├── encrypt-credentials.sh           # Linux/macOS encryption helper
├── encrypt-credentials.ps1          # Windows encryption helper
├── setup-postgresql.sql             # Database initialization
│
├── product-service/                 # Product Microservice
│   ├── Dockerfile
│   ├── templates/                   # Kubernetes YAML templates
│   └── src/main/resources/
│       ├── application.properties
│       └── application-prod-encrypted.properties
│
├── order-service/                   # Order Microservice
│   ├── Dockerfile
│   ├── templates/                   # Kubernetes YAML templates
│   └── src/main/resources/
│       ├── application.properties
│       └── application-prod-encrypted.properties
│
├── frontend-service/                # Frontend Application
│   ├── Dockerfile
│   ├── templates/                   # Kubernetes YAML templates
│   └── src/main/resources/
│
└── k8s/                             # Kubernetes shared resources
    ├── namespace.yaml
    ├── postgres-secret.yaml         # PostgreSQL credentials
    ├── postgres-init-config.yaml    # DB initialization
    ├── kustomization.yaml           # Master Kustomize config
    └── README.md
```

## 📝 Configuration Files

### Default Values

```properties
# Application Properties
server.port=8081                    # Service port
spring.datasource.username=postgres # DB user
spring.datasource.password=postgres # DB password

# Jasypt (when using encryption)
jasypt.encryptor.password=<your-key>
jasypt.encryptor.algorithm=PBEWITHHMACSHA512ANDAES_256
```

### Override Methods (Precedence)

1. Command line: `--spring.datasource.username=value`
2. Environment: `SPRING_DATASOURCE_USERNAME=value`
3. Profile-specific: `application-prod.properties`
4. Default: `application.properties`

## 🧪 Testing Connectivity

### Test from Docker Compose
```bash
# Access product service from order service
docker exec ecommerce-order-service curl http://product-service:8081/api/products
```

### Test from Kubernetes
```bash
# Access product service from pod
kubectl exec -it <order-pod> -n ecommerce \
  -- curl http://product-service:8081/api/products
```

## 🐛 Troubleshooting

### Service won't start
```bash
# Check logs
docker-compose logs product-service
# or
kubectl logs <pod-name> -n ecommerce
```

### Can't connect to database
```bash
# Verify database is running
docker-compose ps postgres
# or
kubectl get pod postgres -n ecommerce

# Check credentials
echo $SPRING_DATASOURCE_USERNAME
echo $SPRING_DATASOURCE_PASSWORD
```

### Encryption error
```bash
# Verify key is correct
jasypt decrypt input=ENC(...) password=your_key

# Re-encrypt if needed
jasypt encrypt input=value password=correct_key
```

## 📞 Support

Check these files for detailed help:
- Service logs: `docker-compose logs -f`
- Kubernetes logs: `kubectl logs -f pod-name -n ecommerce`
- Configuration: `application*.properties` files
- Security setup: `PROPERTIES_OVERRIDE_GUIDE.md`

---

**Status**: Production Ready  
**Version**: 1.0.0  
**Updated**: March 6, 2026

</xai:function_call name="create_file">
<parameter name="content"># E-Commerce Microservices

A production-ready microservices architecture for e-commerce with three services:

## Services

### 1. Product Service (Port 8081)
- **Purpose**: Product catalog management
- **Features**: Create, list, get products by ID
- **Database**: H2 in-memory (configurable to PostgreSQL)

### 2. Order Service (Port 8082)
- **Purpose**: Order management and processing
- **Features**: Create orders, fetch orders, validate products
- **Database**: H2 in-memory (configurable to PostgreSQL)
- **Integration**: Calls Product Service for validation

### 3. Frontend Service (Port 8080)
- **Purpose**: Web UI for the e-commerce system
- **Features**: Product browsing, order creation, order tracking
- **Technology**: Spring Boot with JSP

## Prerequisites
- Java 8+
- Maven 3.6+
- PostgreSQL 12+

### Database Setup
1. Install PostgreSQL
2. Create databases:
   ```sql
   CREATE DATABASE product_db;
   CREATE DATABASE order_db;
   ```
3. Run setup script:
   ```bash
   psql -U postgres -f setup-postgresql.sql
   ```

Or run the schema files manually:
```bash
psql -U postgres -d product_db -f product-service/src/main/resources/schema.sql
psql -U postgres -d order_db -f order-service/src/main/resources/schema.sql
```
```bash
mvn clean package
```

### Run Services
```bash
# Terminal 1 - Product Service
java -jar product-service/target/product-service-1.0.0.jar

# Terminal 2 - Order Service
java -jar order-service/target/order-service-1.0.0.jar

# Terminal 3 - Frontend Service
java -jar frontend-service/target/frontend-service-1.0.0.war
```

### Access Application
- **Frontend UI**: http://localhost:8080/ecommerce
- **Product API**: http://localhost:8081/api/products
- **Order API**: http://localhost:8082/api/orders
- **H2 Console**: http://localhost:8081/h2-console (Product DB)

## Configuration

### Production (PostgreSQL - Default)
- Uses PostgreSQL databases: `product_db` and `order_db`
- Tables auto-created via Hibernate with `ddl-auto=update`
- Sample data inserted via `schema.sql`

### Development (H2 In-Memory)
To switch to H2 for development/testing:
1. Uncomment H2 configuration in `application.properties`
2. Comment out PostgreSQL configuration
3. Change Hibernate dialect to `H2Dialect`

## API Endpoints

### Product Service
- `POST /api/products` - Create product
- `GET /api/products` - List all products
- `GET /api/products/{id}` - Get product by ID
- `GET /api/products/validate/{id}` - Validate product exists

### Order Service
- `POST /api/orders` - Create order (validates product)
- `GET /api/orders` - List all orders
- `GET /api/orders/{id}` - Get order by ID
- `GET /api/orders/customer/{name}` - Search by customer

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Order Service │    │ Product Service │
│   (Port 8080)   │◄──►│   (Port 8082)   │◄──►│   (Port 8081)   │
│                 │    │                 │    │                 │
│ • Web UI        │    │ • Order Mgmt    │    │ • Product Mgmt  │
│ • JSP Views     │    │ • Product Val.  │    │ • CRUD Ops      │
│ • API Client    │    │ • REST API      │    │ • REST API      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                    ┌─────────────────┐
                    │ PostgreSQL      │
                    │ Databases       │
                    │ • product_db    │
                    │ • order_db      │
                    └─────────────────┘
```

## Development

### Build Individual Services
```bash
# Build specific service
mvn clean package -pl product-service

# Build multiple services
mvn clean package -pl product-service,order-service
```

### Run Tests
```bash
mvn test
```

### Profiles
- `dev` (default): Development with H2
- `prod`: Production configuration

```bash
mvn clean package -P prod
```