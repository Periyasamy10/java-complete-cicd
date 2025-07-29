# Stage 1: Build the app using Gradle
FROM gradle:8.4-jdk21 AS builder

WORKDIR /app
COPY . .
RUN ./gradlew installDist

# Stage 2: Create a lightweight runtime image
FROM eclipse-temurin:21-jre

WORKDIR /app
ENV APP_PORT=9100
EXPOSE 9100

COPY --from=builder /app/build/install/java-gradle-webapp /app

# Run the app
ENTRYPOINT ["./bin/java-gradle-webapp"]
