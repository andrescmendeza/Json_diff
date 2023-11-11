# Json Diff
Provide 2 http endpoints that accepts JSON base64 encoded binary data on
both endpoints: 

/v1/diff/left and /v1/diff/right

The provided data needs to be diff-ed and the results shall be available on a third end point: 
• /v1/diff/

The results shall provide the following info in JSON format. Return the information if the data are equal or not.If:

• They don’t have the same size return this information.
• They have the same size but are not equal, provide information about where the differences are. Ex.: offsets + length in the data.

Make assumptions in the implementation explicit, choices are good but need to be communicated.

### How it works:
Provide 2 Rest Api endpoints that receive JSON base64 encoded binary data on both endpoints;

```
[POST] http://localhost:8080/v1/diff/right
{
  "data": "SG9sYSBMb3JlbnphICEhIQ=="  // Example base64 encoded binary data
}

[Result] 200
Right data received successfully: Data_value

[POST] http://localhost:8080/v1/diff/left
{
  "data": "SG9sYSBMb3JlbnphICEhIQ=="  // Example base64 encoded binary data
}

[Result] 200
Left data received successfully: Data_value
```

Provide a endpoint for diff comparison between them.
- Get: http://localhost:8080/v1/diff
- The results provide the following info in JSON format:


- Jsons are equal, same size, different size, same size but with differences

```
[Result] 200
{
    "equal": false,
    "message": "Data size is different.",
    "differences": []
}
```

### Techonologies
- Springboot
- Java 11
- UnitTest
- Docker
- AWS: Ec2, Lambda, API gateway
- IAC Terraform

### Architectural diagram 

Architectural diagram involves multiple components, and in this case uses a Spring Boot application on AWS using containers and Elastic Container Registry (ECR). These are the basic components involved:

Amazon Elastic Container Registry (ECR): Hosts Docker container images.

Amazon Elastic Container Service (ECS):
Orchestrates and manages the Docker containers.
Runs and scales the Spring Boot application containers.

Spring Boot Application: Containerized using Docker. Images stored in ECR.

Amazon API Gateway: Handles incoming HTTP requests and routes them to the appropriate ECS service.

Amazon EC2 Instances: ECS may use EC2 instances as underlying hosts for the containers.

AWS VPC (Virtual Private Cloud): Provides network isolation for resources. Security groups and network ACLs control traffic flow.


## Terraform Manifest

The Terraform script uses the AWS provider to configure the deployment in the specified region.

The EC2 instance resource (aws_instance) deploys an instance with the specified AMI, instance type, and user data script that installs Java and runs your Spring Boot application.

The API Gateway resources (aws_api_gateway_rest_api, aws_api_gateway_resource, aws_api_gateway_method) are created to handle the API endpoint.

The Lambda function resource (aws_lambda_function) deploys a Lambda function with the specified handler, runtime, and IAM role.

The IAM role (aws_iam_role) and IAM policy (aws_iam_policy) are created to grant the necessary permissions for the Lambda function.

The IAM policy attachment (aws_iam_role_policy_attachment) associates the policy with the IAM role.

### CICD Pipeline

The workflow is triggered on every push to the main branch.

The build job checks out the code, sets up JDK 11, and builds the Spring Boot application with Maven.

The deploy job, which depends on the build job, deploys the application to an AWS EC2 instance using SSH. Replace the placeholders like /path/to/your with your actual paths, and adjust the service name (your-application-service) and JAR file name accordingly.

It was added a new step named "Run Unit Tests" that uses the mvn test command to execute your Maven tests.

This step is placed after the build step (mvn clean install) to ensure that the unit tests are run after the application is built.

GitHub Actions workflow includes a unit test step before deploying to AWS EC2. 

The deploy job now includes steps to log in to AWS ECR, build the Docker image, push it to ECR, and then SSH into your EC2 instance to pull and run the Docker image.


### Suggestion to improve
- Distribute the application in containers Docker (implemented)
- Apply Unit, AutoMapper, SOLID techniques
- Use high availability configuration (implemented)
- Use kubernetes cluster to implement (horizontal) scalability.
- Create independent IAC repository for infrastructure provisioning. Creation of terraform modules for code reuse in the creation of EC2 instances
