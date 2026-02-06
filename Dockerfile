# Build stage
FROM gradle:8.5-jdk17 AS builder

WORKDIR /app

# Copy gradle files
COPY build.gradle.kts gradle.properties settings.gradle.kts ./

# Copy source code
COPY src ./src

# Build the application
RUN gradle build -x test

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy the built JAR from builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Set environment variables
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
