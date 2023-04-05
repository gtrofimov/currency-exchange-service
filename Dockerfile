FROM openjdk:11.0-jdk

LABEL mentainer="gtrfoimov@parasoft.com"

WORKDIR /app

COPY /target/currency-exchange-service-0.0.1-SNAPSHOT.jar /app/currency-exchange-service.jar

#ENV JAVA_TOOL_OPTIONS '-javaagent:"/monitor/agent.jar"=settings="/monitor/agent.properties",runtimeData=/monitor/runtime_coverage",autostart=false,collectTestCoverage=true'

EXPOSE 8000 8050

#ENTRYPOINT ["java", "-jar", "currency-exchange-service.jar"]
ENTRYPOINT [ "tail", "-f", "/dev/null" ]