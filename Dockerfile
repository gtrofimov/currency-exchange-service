FROM adoptopenjdk/openjdk11:alpine-slim

LABEL maintainer="gtrofimov@parasoft.com"

WORKDIR /app

COPY /target/currency-exchange-service-0.0.1-SNAPSHOT.jar /app/currency-exchange-service.jar

EXPOSE 8000 8050

#ENTRYPOINT ["java", "-jar", "currency-exchange-service.jar"]
ENTRYPOINT [ "tail", "-f", "/dev/null" ]