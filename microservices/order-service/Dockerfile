# Build stage
FROM maven:3.8.6-openjdk-8 as builder

WORKDIR /build

# Copy parent pom and settings
COPY ../pom.xml ./
COPY ../settings.xml ./

# Copy order-service
COPY ./ ./order-service/

# Build order-service
RUN mvn -s settings.xml clean package -DskipTests -pl order-service

# Runtime stage
FROM openjdk:8-jdk-alpine

WORKDIR /app

# Copy JAR from builder
COPY --from=builder /build/order-service/target/order-service-1.0.0.jar ./app.jar

# Expose port
EXPOSE 8082

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8082/actuator/health || exit 1

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
