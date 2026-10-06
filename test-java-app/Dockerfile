# Стадия сборки с Maven
FROM registry:5000/maven:3.9.14-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Стадия запуска
FROM registry:5000/eclipse-temurin:21.0.10_7-jdk-jammy
WORKDIR application
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]