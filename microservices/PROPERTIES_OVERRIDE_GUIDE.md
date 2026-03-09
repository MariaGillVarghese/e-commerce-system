# Credential & Properties Management Guide

This guide explains how to manage database credentials and override properties in different deployment scenarios.

## Quick Reference

| Method | Dev | Docker | Kubernetes | Security |
|--------|-----|--------|------------|----------|
| Default properties | ✓ | ✗ | ✗ | Low |
| Env variables | ✓ | ✓ | ✓ | Medium |
| Jasypt encryption | ✓ | ✓ | ✓ | High |
| Cloud secrets | ✗ | ✓ | ✓ | Very High |

## Method 1: Environment Variables (NO CODE CHANGES NEEDED!)

Spring Boot automatically converts environment variables to properties using this pattern:
- Dots (.) → Underscores (_)
- Lowercase → UPPERCASE
- Example: `spring.datasource.password` → `SPRING_DATASOURCE_PASSWORD`

### Windows (PowerShell)

```powershell
# Set environment variables
$env:SPRING_DATASOURCE_USERNAME = "prod_user"
$env:SPRING_DATASOURCE_PASSWORD = "SecurePassword123!"
$env:SPRING_DATASOURCE_URL = "jdbc:postgresql://prod-db.example.com:5432/product_db"

# Run service
java -jar product-service-1.0.0.jar

# Verify variables are set
Get-ChildItem env: | Where-Object {$_.Name -like "*SPRING*"}
```

### Linux/macOS (Bash)

```bash
# Set environment variables
export SPRING_DATASOURCE_USERNAME="prod_user"
export SPRING_DATASOURCE_PASSWORD="SecurePassword123!"
export SPRING_DATASOURCE_URL="jdbc:postgresql://prod-db.example.com:5432/product_db"

# Run service
java -jar product-service-1.0.0.jar

# Verify variables are set
env | grep SPRING
```

### Docker Compose

**docker-compose.yml** (already configured):
```yaml
product-service:
  build: ./product-service
  environment:
    SPRING_DATASOURCE_USERNAME: prod_user
    SPRING_DATASOURCE_PASSWORD: SecurePassword123!
    SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/product_db
    SPRING_JPA_HIBERNATE_DDL_AUTO: update
```

Run:
```bash
docker-compose up -d
```

### Kubernetes

**k8s/postgres-secret.yaml** (already configured):
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

Update the secret:
```bash
kubectl create secret generic postgres-credentials \
  --from-literal=username=prod_user \
  --from-literal=password=SecurePassword123! \
  -n ecommerce --dry-run=client -o yaml | kubectl apply -f -
```

Deploy:
```bash
kubectl apply -k product-service/templates/
```

## Method 2: Command Line Arguments

```bash
java -jar product-service-1.0.0.jar \
  --spring.datasource.username=prod_user \
  --spring.datasource.password=SecurePassword123! \
  --spring.datasource.url=jdbc:postgresql://prod-db.example.com:5432/product_db \
  --spring.jpa.hibernate.ddl-auto=update
```

### With Multiple Properties

```bash
java -jar order-service-1.0.0.jar \
  --server.port=9082 \
  --spring.datasource.username=order_user \
  --spring.datasource.password=OrderDbPassword \
  --product.service.url=http://product-service:8081 \
  --logging.level.com.ecommerce=DEBUG
```

## Method 3: Jasypt Encryption (Recommended for Production)

Jasypt provides property-level encryption while still supporting all the override methods above.

### Step 1: Install Jasypt

**macOS:**
```bash
brew install jasypt
```

**Windows (with Chocolatey):**
```powershell
choco install jasypt
```

**Or download manually:**
1. Visit: https://github.com/ulisesbocchio/jasypt-spring-boot/releases
2. Download jasypt binary
3. Add to system PATH

### Step 2: Generate Encryption Key

**Option A: Using OpenSSL (Recommended)**
```bash
# Generate 256-bit key (32 bytes)
openssl rand -base64 32
# Output: 9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2

# Store it somewhere safe!
export MASTER_KEY="9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2"
```

**Option B: Using PowerShell**
```powershell
# Generate 256-bit key
$bytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
$rng.GetBytes($bytes)
$key = [Convert]::ToBase64String($bytes)
Write-Host "Generated Key: $key"
```

**Option C: Using provided script**
```bash
# Linux/macOS
chmod +x ./encrypt-credentials.sh
./encrypt-credentials.sh postgres your_encryption_key

# Windows
.\encrypt-credentials.ps1 -Value "postgres" -Key "your_encryption_key"
```

### Step 3: Encrypt Your Credentials

```bash
# Encrypt username
jasypt encrypt input=prod_user password=9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2 \
  algorithm=PBEWITHHMACSHA512ANDAES_256
# Output: qU2rZ7lK3mN9pL5sX8vT0kJ2hG6fD4bE

# Encrypt password
jasypt encrypt input=SecurePassword123! password=9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2 \
  algorithm=PBEWITHHMACSHA512ANDAES_256
# Output: dF5tK8mP2qR7xE0vC3nL9sJ4yH6bZ1wA
```

### Step 4: Use Encrypted Values in Properties

**application-prod-encrypted.properties** (already created):
```properties
spring.datasource.username=ENC(qU2rZ7lK3mN9pL5sX8vT0kJ2hG6fD4bE)
spring.datasource.password=ENC(dF5tK8mP2qR7xE0vC3nL9sJ4yH6bZ1wA)
spring.datasource.url=jdbc:postgresql://prod-db.example.com:5432/product_db

# Jasypt will automatically decrypt these on startup
```

### Step 5: Run with Encryption Key

**Method A: Environment Variable (Best)**
```bash
# Linux/macOS
export JASYPT_ENCRYPTOR_PASSWORD="9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2"
java -jar product-service-1.0.0.jar --spring.profiles.active=prod-encrypted

# Windows (PowerShell)
$env:JASYPT_ENCRYPTOR_PASSWORD = "9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2"
java -jar product-service-1.0.0.jar --spring.profiles.active=prod-encrypted
```

**Method B: Command Line Argument**
```bash
java -jar product-service-1.0.0.jar \
  --jasypt.encryptor.password=9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2 \
  --spring.profiles.active=prod-encrypted
```

**Method C: In application.properties (NOT recommended!)**
```properties
jasypt.encryptor.password=9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2
```

### Docker Compose with Encryption

```yaml
services:
  product-service:
    build: ./product-service
    environment:
      JASYPT_ENCRYPTOR_PASSWORD: 9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2
      SPRING_DATASOURCE_USERNAME: ENC(qU2rZ7lK3mN9pL5sX8vT0kJ2hG6fD4bE)
      SPRING_DATASOURCE_PASSWORD: ENC(dF5tK8mP2qR7xE0vC3nL9sJ4yH6bZ1wA)
      SPRING_PROFILES_ACTIVE: prod-encrypted
```

### Kubernetes with Encryption

Create secrets for both database and encryption key:
```bash
kubectl create secret generic postgres-credentials \
  --from-literal=username=prod_user \
  --from-literal=password=SecurePassword123! \
  -n ecommerce

kubectl create secret generic jasypt-key \
  --from-literal=password=9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2 \
  -n ecommerce
```

Update **product-service/templates/deployment.yaml**:
```yaml
env:
- name: JASYPT_ENCRYPTOR_PASSWORD
  valueFrom:
    secretKeyRef:
      name: jasypt-key
      key: password
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
- name: SPRING_PROFILES_ACTIVE
  value: "prod-encrypted"
```

Deploy:
```bash
kubectl apply -k product-service/templates/
```

## Method 4: Application-Specific Property Files

### Using Spring Profiles

**application.properties** (default):
```properties
spring.datasource.username=postgres
spring.datasource.password=postgres
```

**application-prod.properties** (production):
```properties
spring.datasource.username=prod_user
spring.datasource.password=prod_password
spring.datasource.url=jdbc:postgresql://prod-db.example.com:5432/product_db
```

**application-prod-encrypted.properties** (production with encryption):
```properties
spring.datasource.username=ENC(encrypted_username)
spring.datasource.password=ENC(encrypted_password)
spring.datasource.url=jdbc:postgresql://prod-db.example.com:5432/product_db
```

### Activate Profile at Runtime

```bash
# Using command line
java -jar product-service-1.0.0.jar --spring.profiles.active=prod

# Using environment variable
export SPRING_PROFILES_ACTIVE=prod
java -jar product-service-1.0.0.jar

# Multiple profiles
java -jar product-service-1.0.0.jar --spring.profiles.active=prod,encrypted
```

## Complete Scenario Examples

### Scenario 1: Local Development (No Security Needed)

**Run:**
```bash
java -jar product-service-1.0.0.jar
```

**Uses:** application.properties with:
- localhost:5432
- username: postgres
- password: postgres

### Scenario 2: Docker Development (Medium Security)

**Run:**
```bash
docker-compose up -d
```

**Uses:** docker-compose.yml environment overrides:
```yaml
SPRING_DATASOURCE_USERNAME: dev_user
SPRING_DATASOURCE_PASSWORD: devPassword123
```

### Scenario 3: Kubernetes Development (Medium Security)

**Run:**
```bash
kubectl create secret generic postgres-credentials \
  --from-literal=username=dev_user \
  --from-literal=password=devPassword123 \
  -n ecommerce

kubectl apply -k product-service/templates/
```

**Uses:** Kubernetes Secret values mounted as environment variables

### Scenario 4: Production with Full Security

**Generate encryption key:**
```bash
openssl rand -base64 32
# Save: 9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2
```

**Encrypt credentials:**
```bash
jasypt encrypt input=prod_admin password=9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2
# Result: qU2rZ7lK3mN9pL5sX8vT0kJ2hG6fD4bE

jasypt encrypt input=SuperSecurePassword123! password=9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2
# Result: dF5tK8mP2qR7xE0vC3nL9sJ4yH6bZ1wA
```

**application-prod-encrypted.properties:**
```properties
spring.datasource.username=ENC(qU2rZ7lK3mN9pL5sX8vT0kJ2hG6fD4bE)
spring.datasource.password=ENC(dF5tK8mP2qR7xE0vC3nL9sJ4yH6bZ1wA)
spring.datasource.url=jdbc:postgresql://prod-db.example.com:5432/product_db
```

**Run:**
```bash
export JASYPT_ENCRYPTOR_PASSWORD="9mPL5K8nJ2xH7vQ3bR8wT9dL4kP6sF0zM3xC5yK9pL2"
java -jar product-service-1.0.0.jar --spring.profiles.active=prod-encrypted
```

## Property Precedence (Highest to Lowest)

1. Command line: `--spring.datasource.username=value`
2. Environment variable: `export SPRING_DATASOURCE_USERNAME=value`
3. System property: `java -Dspring.datasource.username=value`
4. Profile-specific file: `application-prod.properties`
5. Default file: `application.properties`

## Files Created

- **CREDENTIALS_MANAGEMENT.md** - Detailed credential management guide
- **encrypt-credentials.sh** - Linux/macOS encryption helper script
- **encrypt-credentials.ps1** - Windows PowerShell encryption helper script
- **product-service/src/main/resources/application-prod-encrypted.properties** - Example encrypted properties
- **order-service/src/main/resources/application-prod-encrypted.properties** - Example encrypted properties
- **frontend-service/src/main/resources/application-prod-encrypted.properties** - Example encrypted properties

## Security Best Practices

✅ **DO:**
- Use environment variables for secrets
- Use Jasypt encryption for production
- Store encryption keys in secure vaults
- Rotate credentials periodically
- Use strong passwords (16+ characters)
- Limit database user permissions
- Use HTTPS for all connections

❌ **DON'T:**
- Hardcode credentials in code
- Commit passwords to Git
- Share credentials via email/Slack
- Use weak passwords
- Store encryption keys in code
- Use same password everywhere
- Log sensitive values
- Trust user input

## Troubleshooting

### "Could not decrypt property" Error

**Solution:**
```bash
# Verify encryption key is correct
jasypt decrypt input=ENC(...) password=your_key

# If fails, re-encrypt with correct key
jasypt encrypt input=value password=correct_key
```

### Property Not Overridden

**Check:**
```bash
# Verify env var is set (Linux/macOS)
echo $SPRING_DATASOURCE_USERNAME

# Verify env var is set (Windows PowerShell)
$env:SPRING_DATASOURCE_USERNAME

# Verify app started with correct profile
java -jar service-1.0.0.jar --spring.profiles.active=prod
```

### Docker Can't Connect to Database

**Check:**
1. Database hostname is correct (postgres in docker-compose, not localhost)
2. Database is running: `docker-compose ps`
3. Credentials are correct
4. Network is correct: `docker network ls`

### Kubernetes Can't Access Secrets

**Check:**
```bash
# Verify secret exists
kubectl get secret postgres-credentials -n ecommerce

# Verify secret values
kubectl get secret postgres-credentials -n ecommerce -o yaml

# Verify pod can mount secret
kubectl describe pod <pod-name> -n ecommerce
```

## Additional Resources

- [Jasypt GitHub](https://github.com/ulisesbocchio/jasypt-spring-boot)
- [Spring Boot Properties](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config)
- [12 Factor App - Config](https://12factor.net/config)
- [OWASP Secret Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
