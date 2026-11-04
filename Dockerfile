# ============================================
# STAGE 1: BUILD
# ============================================
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy pom.xml first (for better caching)
COPY pom.xml .

# Download dependencies (cached if pom.xml doesn't change)
# This means that it does not have to download dependencies every time the source code changes and we do a build
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# ============================================
# STAGE 2: RUN
# ============================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy JAR from build stage
# COPY --from=build /app/target/simple-crm-lite-0.0.1-SNAPSHOT.jar app.jar
# reason of using a wildcard is to avoid hardcoding the exact JAR file name, 
# which may change with each build version
COPY --from=build /app/target/*.jar app.jar


EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]