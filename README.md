# StartTech Infrastructure as Code (IaC)

## Overview
This repository contains the Terraform configurations required to provision the complete AWS infrastructure for the StartTech application. The infrastructure is designed to be highly available, scalable, and secure, supporting a containerized Golang backend and a static React frontend.


## Prerequisites
To deploy or modify this infrastructure, you must have the following installed and configured:
* **Terraform** (v1.5.0 or higher)
* **AWS CLI** (configured with Administrator or required IAM permissions)
* An active AWS Account

## Repository Structure
* `main.tf`: Defines the core provider configuration and root module calls.
* `variables.tf`: Contains all configurable variables for the environments.
* `outputs.tf`: Defines the critical infrastructure outputs (e.g., ALB DNS, S3 Bucket name).
* `network/`: VPC, Subnets, Internet Gateway, and Route Tables.
* `compute/`: Auto Scaling Group, Launch Templates, and Application Load Balancer.
* `storage/`: S3 Bucket and CloudFront distribution for the frontend.
* `security/`: IAM Roles and Security Groups.

## Deployment Instructions

1. **Initialize Terraform:**
   Downloads the required AWS provider plugins.
   ```bash
   terraform init
   ```
2. **Validate Configuration:**
Ensures the syntax and structure of the configuration are correct.
 ```bash
   terraform validate
   ```

3. **Plan the Deployment:**
Generates an execution plan showing exactly what resources will be created.
```bash
terraform plan 
```

4. **Apply the Infrastructure:**
Provides the resources in your AWS account.
```bash
terraform apply tfplan
```
