# Build stage
FROM maven:3.8.6-openjdk-8 as builder

WORKDIR /build

# Copy parent pom and settings
COPY ../pom.xml ./
COPY ../settings.xml ./

# Copy product-service
COPY ./ ./product-service/

# Build product-service
RUN mvn -s settings.xml clean package -DskipTests -pl product-service

# Runtime stage
FROM openjdk:8-jdk-alpine

WORKDIR /app

# Copy JAR from builder
COPY --from=builder /build/product-service/target/product-service-1.0.0.jar ./app.jar

# Expose port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8081/actuator/health || exit 1

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
