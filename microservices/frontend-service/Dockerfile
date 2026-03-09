# Build stage
FROM maven:3.8.6-openjdk-8 as builder

WORKDIR /build

# Copy parent pom and settings
COPY ../pom.xml ./
COPY ../settings.xml ./

# Copy frontend-service
COPY ./ ./frontend-service/

# Build frontend-service
RUN mvn -s settings.xml clean package -DskipTests -pl frontend-service

# Runtime stage
FROM tomcat:8.5-jdk8-openjdk

WORKDIR /usr/local/tomcat

# Remove default ROOT application
RUN rm -rf webapps/ROOT

# Copy WAR from builder
COPY --from=builder /build/frontend-service/target/ecommerce-frontend.war ./webapps/ROOT.war

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ecommerce || exit 1

# Run Tomcat
CMD ["catalina.sh", "run"]
