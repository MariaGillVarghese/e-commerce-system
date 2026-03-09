# Secure Credentials Management Guide

This guide shows how to encrypt database credentials and override them in different environments.

## Overview

Your microservices support multiple ways to manage and override credentials:

1. **Property override** (easiest) - Environment variables
2. **Encryption** (secure) - Jasypt property encryption
3. **Cloud secrets** (enterprise) - Cloud provider secret managers

## Part 1: Property Override Methods (Already Supported!)

No code changes needed. Spring Boot automatically reads these in order:

### 1A. Environment Variables (RECOMMENDED)

**Windows (PowerShell):**
```powershell
# Set environment variables
$env:SPRING_DATASOURCE_USERNAME = "prod_user"
$env:SPRING_DATASOURCE_PASSWORD = "SecurePassword123!"

# Run service
java -jar product-service-1.0.0.jar
```

**Linux/Mac (Bash):**
```bash
# Set environment variables
export SPRING_DATASOURCE_USERNAME="prod_user"
export SPRING_DATASOURCE_PASSWORD="SecurePassword123!"

# Run service
java -jar product-service-1.0.0.jar
```

### 1B. Command Line Arguments

```bash
java -jar product-service-1.0.0.jar \
  --spring.datasource.username=prod_user \
  --spring.datasource.password=SecurePassword123! \
  --spring.datasource.url=jdbc:postgresql://prod-db.example.com:5432/product_db
```

### 1C. Docker Compose (Already Configured!)

```yaml
environment:
  SPRING_DATASOURCE_USERNAME: prod_user
  SPRING_DATASOURCE_PASSWORD: SecurePassword123!
  SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/product_db
```

**Run it:**
```bash
docker-compose up -d
```

### 1D. Kubernetes (Already Configured!)

Update the secret:
```bash
kubectl create secret generic postgres-credentials \
  --from-literal=username=prod_user \
  --from-literal=password=SecurePassword123! \
  -n ecommerce --dry-run=client -o yaml | kubectl apply -f -
```

Then deploy:
```bash
kubectl apply -k product-service/templates/
```

## Part 2: Encrypt Credentials with Jasypt

For additional security, encrypt credentials in property files.

### Step 1: Generate Encryption Key

Choose one method:

**Method A: Using OpenSSL (Recommended)**
```bash
# Generate 256-bit random key
openssl rand -base64 32
# Example output: 9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2

# Or 128-bit (if needed)
openssl rand -base64 16
# Example output: jK7mN3xL9pP2qR5t
```

**Method B: Using Java**
```bash
java -cp "~/.m2/repository/org/jasypt/jasypt/1.9.3/jasypt-1.9.3.jar" \
  org.jasypt.zcrypt.ZeroableChar
```

**Method C: Online Tool** (for testing only, NOT production)
[jasypt.org](http://www.jasypt.org/)

### Step 2: Encrypt Your Credentials

Using Jasypt CLI (install: `brew install jasypt` or download from GitHub):

```bash
# Encrypt username
jasypt encrypt input=postgres \
  algorithm=PBEWITHHMACSHA512ANDAES_256 \
  password=your_encryption_key

# Output: qU2rZ7lK3mN9pL5sX8vT0kJ2hG6fD4bE

# Encrypt password  
jasypt encrypt input=SecurePassword123! \
  algorithm=PBEWITHHMACSHA512ANDAES_256 \
  password=your_encryption_key

# Output: dF5tK8mP2qR7xE0vC3nL9sJ4yH6bZ1wA
```

Or use an online Jasypt tool for testing.

### Step 3: Add Encrypted Values to Properties

**application.properties** (or application-prod.properties):
```properties
# Encrypted with your_encryption_key
spring.datasource.username=ENC(qU2rZ7lK3mN9pL5sX8vT0kJ2hG6fD4bE)
spring.datasource.password=ENC(dF5tK8mP2qR7xE0vC3nL9sJ4yH6bZ1wA)
spring.datasource.url=jdbc:postgresql://localhost:5432/product_db
```

### Step 4: Provide Encryption Key at Startup

Choose one method:

**Method A: Environment Variable (RECOMMENDED)**
```bash
# Windows (PowerShell)
$env:JASYPT_ENCRYPTOR_PASSWORD = "your_encryption_key"
java -jar product-service-1.0.0.jar

# Linux/Mac
export JASYPT_ENCRYPTOR_PASSWORD="your_encryption_key"
java -jar product-service-1.0.0.jar
```

**Method B: Command Line Argument**
```bash
java -jar product-service-1.0.0.jar \
  --jasypt.encryptor.password=your_encryption_key
```

**Method C: application.properties**
```properties
jasypt.encryptor.password=your_encryption_key
jasypt.encryptor.algorithm=PBEWITHHMACSHA512ANDAES_256
```

**Method D: Docker Compose**
```yaml
environment:
  JASYPT_ENCRYPTOR_PASSWORD: your_encryption_key
  SPRING_DATASOURCE_USERNAME: ENC(qU2rZ7lK3mN9pL5sX8vT0kJ2hG6fD4bE)
  SPRING_DATASOURCE_PASSWORD: ENC(dF5tK8mP2qR7xE0vC3nL9sJ4yH6bZ1wA)
```

**Method E: Kubernetes Secret**
```bash
kubectl create secret generic jasypt-key \
  --from-literal=password=your_encryption_key \
  -n ecommerce
```

Then reference in Deployment:
```yaml
env:
  - name: JASYPT_ENCRYPTOR_PASSWORD
    valueFrom:
      secretKeyRef:
        name: jasypt-key
        key: password
```

## Part 3: Complete Example Scenarios

### Scenario 1: Local Development (No Encryption)

**Run application:**
```bash
java -jar product-service-1.0.0.jar
```

**Uses default properties** in application.properties:
```properties
spring.datasource.username=postgres
spring.datasource.password=postgres
```

### Scenario 2: Docker Compose with Override

**docker-compose.yml:**
```yaml
services:
  product-service:
    build: ./product-service
    ports:
      - "8081:8081"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/product_db
      SPRING_DATASOURCE_USERNAME: prod_user
      SPRING_DATASOURCE_PASSWORD: SecurePassword123!
```

**Run:**
```bash
docker-compose up -d
```

### Scenario 3: Kubernetes with Encrypted Values

**k8s/postgres-secret.yaml:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
  namespace: ecommerce
type: Opaque
stringData:
  username: prod_user
  password: SecurePassword123!
```

**product-service/templates/deployment.yaml:**
```yaml
env:
- name: SPRING_DATASOURCE_USERNAME
  valueFrom:
    secretKeyRef:
      name: postgres-credentials
      key: username
- name: SPRING_DATASOURCE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: postgres-credentials
      key: password
- name: JASYPT_ENCRYPTOR_PASSWORD
  valueFrom:
    secretKeyRef:
      name: jasypt-key
      key: password
```

**Deploy:**
```bash
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -k product-service/templates/
```

### Scenario 4: Production with Jasypt Encryption

**Create encrypted values:**
```bash
jasypt encrypt input=prod_user password=MyMasterKey >>> ENC(qU2rZ7lK...)
jasypt encrypt input=SecurePassword123! password=MyMasterKey >>> ENC(dF5tK8mP...)
```

**application-prod.properties:**
```properties
spring.datasource.username=ENC(qU2rZ7lK3mN9pL5sX8vT0kJ2hG6fD4bE)
spring.datasource.password=ENC(dF5tK8mP2qR7xE0vC3nL9sJ4yH6bZ1wA)
spring.datasource.url=jdbc:postgresql://prod-db.example.com:5432/product_db
```

**Run with encryption key:**
```bash
export JASYPT_ENCRYPTOR_PASSWORD=MyMasterKey
java -jar product-service-1.0.0.jar --spring.profiles.active=prod
```

## Part 4: Best Practices & Security

### Development Environment
- ✅ Use plain text credentials in application.properties
- ✅ Keep passwords simple for ease
- ✅ Never commit real passwords to git

### Docker Development
- ✅ Override credentials via environment variables
- ✅ Use docker-compose.yml for consistency
- ⚠️ Don't hardcode secrets in Dockerfile

### Docker Production
- ✅ Use Jasypt encryption for sensitive values in images
- ✅ Pass encryption key via environment variable
- ✅ Don't commit encryption key to git
- ✅ Use environment-specific property files

### Kubernetes
- ✅ Always use Kubernetes Secrets for credentials
- ✅ Use RBAC to limit secret access
- ✅ Enable secret encryption at rest (Kubernetes 1.13+)
- ✅ Use external secret management (AWS Secrets Manager, Azure Key Vault, HashiCorp Vault)

### All Environments
- ✅ Rotate credentials periodically
- ✅ Use strong passwords (16+ characters, mixed case, numbers, symbols)
- ✅ Never log sensitive values
- ✅ Use HTTPS/TLS for all connections
- ✅ Limit database user permissions (read-only for reporting, etc.)

## Troubleshooting

### "Could not decrypt property"

**Cause:** Wrong encryption key or corrupted encrypted value
```bash
# Verify encryption key
echo "Testing decryption..."
jasypt decrypt input=ENC(...) password=your_key

# If fails, re-encrypt with correct key
```

### "Property not overridden from environment"

**Check:**
1. Environment variable name is correct (snake_case: `SPRING_DATASOURCE_URL`)
2. Variable is exported before running java
3. Application restarted after setting variable

```bash
# Verify environment variable is set
echo $SPRING_DATASOURCE_USERNAME

# Or in PowerShell
$env:SPRING_DATASOURCE_USERNAME
```

### "Connection refused to database"

**Check:**
1. Database hostname is correct (localhost, postgres, prod-db.example.com)
2. Database port is correct (default: 5432)
3. Username and password are correct
4. Database exists (product_db, order_db)
5. Network connectivity (can ping/curl the database host)

## Property Precedence (Highest to Lowest)

1. Command line arguments: `--spring.datasource.username=value`
2. OS environment variables: `SPRING_DATASOURCE_USERNAME=value`
3. Environment-specific properties: `application-prod.properties`
4. Default properties: `application.properties`
5. System properties: `-Dspring.datasource.username=value`

## Encryption Key Management

### DO NOT:
- ❌ Hardcode encryption key in application.properties
- ❌ Commit encryption key to Git
- ❌ Put encryption key in Dockerfile
- ❌ Share encryption key via email/Slack
- ❌ Use weak passwords as encryption keys

### DO:
- ✅ Store key in environment variable
- ✅ Store key in secure vaults (Vault, AWS Secrets Manager)
- ✅ Rotate keys periodically
- ✅ Use strong, random 32+ character keys
- ✅ Restrict access to key (minimum 2 people should know it)

## Example Key Generation Commands

```bash
# 32-byte (256-bit) key - RECOMMENDED
openssl rand -base64 32

# 16-byte (128-bit) key - minimum
openssl rand -base64 16

# Using Python
python3 -c "import os; print(os.urandom(32).hex())"

# Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## Additional Resources

- [Jasypt Spring Boot Documentation](https://github.com/ulisesbocchio/jasypt-spring-boot)
- [Spring Boot Externalized Configuration](https://spring.io/projects/spring-boot)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [12 Factor App: Config](https://12factor.net/config)
