# Use an OpenJDK runtime as a base image
FROM adoptopenjdk:11-jre-hotspot

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file into the container at /app
COPY target/demodiff.jar /app/

# Expose the port that Spring Boot application will run on
EXPOSE 8080

# Specify the command to run on container start
CMD ["java", "-jar", "demodiff.jar"]
