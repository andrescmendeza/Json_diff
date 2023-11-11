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


### Suggestion to improve
- Distribute the application in containers Docker (implemented)
- Apply Unit, AutoMapper, SOLID techniques
- Use high availability configuration (implemented)
- Use kubernetes cluster to implement (horizontal) scalability.
- Create independent IAC repository for infrastructure provisioning. Creation of terraform modules for code reuse in the creation of EC2 instances
