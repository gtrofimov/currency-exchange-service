FROM openjdk:11.0.11-jre-slim

LABEL mentainer="gtrfoimov@parasoft.com"

WORKDIR /app

COPY /target/currency-exchange-service-0.0.1-SNAPSHOT.jar /app/currency-exchange-service.jar

EXPOSE 8000 8050

ENTRYPOINT ["java", "-jar", "currency-exchange-service.jar"]