FROM public.ecr.aws/amazoncorretto/amazoncorretto:17.0.10

EXPOSE 8081

ARG JAR_FILENAME="*.jar"
COPY $JAR_FILENAME /app.jar

ARG CI_ENVIRONMENT="ENV"
ENV CI_ENVIRONMENT=${CI_ENVIRONMENT}


CMD ["java", "-XX:+PrintFlagsFinal", "-Dserver.port=8081", "-jar", "/app.jar"]
