# Docker Deployment Guide

This guide explains how to build and run the E-Commerce microservices using Docker.

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+

## Quick Start (Recommended)

The easiest way to run all services together is using Docker Compose:

```bash
# From the root directory
docker-compose up -d
```

This will:
1. Start PostgreSQL database
2. Build and start Product Service (port 8081)
3. Build and start Order Service (port 8082)
4. Build and start Frontend Service (port 8080)

Access the application:
- **Frontend UI**: http://localhost:8080/ecommerce
- **Product Service API**: http://localhost:8081/api/products
- **Order Service API**: http://localhost:8082/api/orders

## Building Individual Services

If you prefer to build images separately:

### Product Service

```bash
cd product-service
docker build -t ecommerce-product-service:latest .
docker run -p 8081:8081 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/product_db \
  -e SPRING_DATASOURCE_USERNAME=postgres \
  -e SPRING_DATASOURCE_PASSWORD=postgres \
  ecommerce-product-service:latest
```

### Order Service

```bash
cd order-service
docker build -t ecommerce-order-service:latest .
docker run -p 8082:8082 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/order_db \
  -e SPRING_DATASOURCE_USERNAME=postgres \
  -e SPRING_DATASOURCE_PASSWORD=postgres \
  -e PRODUCT_SERVICE_URL=http://host.docker.internal:8081 \
  ecommerce-order-service:latest
```

### Frontend Service

```bash
cd frontend-service
docker build -t ecommerce-frontend-service:latest .
docker run -p 8080:8080 \
  -e PRODUCT_SERVICE_URL=http://host.docker.internal:8081 \
  -e ORDER_SERVICE_URL=http://host.docker.internal:8082 \
  ecommerce-frontend-service:latest
```

## Docker Compose Commands

```bash
# Start services in foreground (view logs)
docker-compose up

# Start services in background
docker-compose up -d

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f product-service

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild all services
docker-compose up -d --build

# Rebuild specific service
docker-compose up -d --build product-service
```

## Pushing to Docker Registry

### Docker Hub

```bash
# Login to Docker Hub
docker login

# Tag images
docker tag ecommerce-product-service:latest your-username/ecommerce-product-service:latest
docker tag ecommerce-order-service:latest your-username/ecommerce-order-service:latest
docker tag ecommerce-frontend-service:latest your-username/ecommerce-frontend-service:latest

# Push images
docker push your-username/ecommerce-product-service:latest
docker push your-username/ecommerce-order-service:latest
docker push your-username/ecommerce-frontend-service:latest
```

## Environment Variables

### Product Service
- `SPRING_DATASOURCE_URL`: PostgreSQL connection URL
- `SPRING_DATASOURCE_USERNAME`: Database user
- `SPRING_DATASOURCE_PASSWORD`: Database password
- `SPRING_JPA_HIBERNATE_DDL_AUTO`: Hibernate DDL mode (create, update, validate)

### Order Service
- `SPRING_DATASOURCE_URL`: PostgreSQL connection URL
- `SPRING_DATASOURCE_USERNAME`: Database user
- `SPRING_DATASOURCE_PASSWORD`: Database password
- `PRODUCT_SERVICE_URL`: Product Service endpoint
- `SPRING_JPA_HIBERNATE_DDL_AUTO`: Hibernate DDL mode

### Frontend Service
- `PRODUCT_SERVICE_URL`: Product Service endpoint
- `ORDER_SERVICE_URL`: Order Service endpoint

## API Endpoints

### Product Service (Port 8081)
- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `GET /api/products/validate/{id}` - Validate product exists
- `POST /api/products` - Create new product

### Order Service (Port 8082)
- `GET /api/orders` - Get all orders
- `GET /api/orders/{id}` - Get order by ID
- `GET /api/orders/customer/{name}` - Get orders by customer name
- `POST /api/orders` - Create new order

### Frontend Service (Port 8080)
- `GET /ecommerce/` - Home page
- `GET /ecommerce/products` - Product list
- `GET /ecommerce/products/{id}` - Product details
- `GET /ecommerce/orders` - Order list
- `GET /ecommerce/orders/{id}` - Order details

## Troubleshooting

### Services can't connect to PostgreSQL
- Ensure PostgreSQL container is running: `docker-compose ps`
- Check if ports are already in use: `docker-compose logs postgres`

### Services can't communicate with each other
- Verify they're on the same network: `docker network inspect ecommerce_ecommerce-network`
- Use container names (not localhost) for inter-service communication

### Port already in use
Change port mappings in docker-compose.yml:
```yaml
ports:
  - "8081:8081"  # Change first number to unused port
```

### Clean rebuild
```bash
docker-compose down -v
docker-compose up -d --build
```

## Performance Notes

- Alpine images are used for smaller image sizes
- Multi-stage builds reduce final image size
- Health checks ensure services are ready before dependent services start
- PostgreSQL data persists in named volume (postgres_data)

## Production Considerations

- Use specific version tags instead of `latest`
- Implement resource limits in compose file
- Use secrets management for sensitive data
- Enable logging drivers for centralized logging
- Configure restart policies appropriately
- Use load balancing for multiple instances
- Implement container orchestration (Kubernetes) for larger deployments
