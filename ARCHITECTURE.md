# StartTech Cloud Architecture

## High-Level Design
The StartTech cloud environment is designed around a classic tiered architecture deployed within the `us-east-1` region. It separates the stateless frontend delivery from the scalable backend compute resources, utilizing AWS managed services wherever possible to reduce operational overhead.

## 1. Networking Layer
* **VPC:** A dedicated Virtual Private Cloud provides a logically isolated network environment.
* **Subnets:** * **Public Subnets:** Span across two Availability Zones (e.g., `us-east-1a`, `us-east-1b`) to ensure high availability. These house the Application Load Balancer (ALB) and NAT Gateways.
* **Internet Gateway (IGW):** Attached to the VPC to allow outbound internet access and inbound traffic to the ALB.

## 2. Compute Layer (Backend)
* **Application Load Balancer (ALB):** Acts as the single point of entry for backend API traffic, distributing incoming requests across healthy EC2 instances in multiple Availability Zones.
* **Auto Scaling Group (ASG):** Manages the lifecycle of the EC2 instances. Configured with a minimum, maximum, and desired capacity.
* **Launch Template:** Defines the configuration for new EC2 instances, including the AMI, instance type (e.g., `t2.micro`), and user data scripts (which pull the latest Golang Docker container from ECR upon startup).

## 3. Storage & Content Delivery (Frontend)
* **Amazon S3:** A private S3 bucket stores the compiled Vite/React static assets.
* **Amazon CloudFront:** A global Content Delivery Network (CDN) sits in front of the S3 bucket. It caches the frontend assets at edge locations worldwide, significantly reducing latency for end-users. Origin Access Control (OAC) ensures the S3 bucket can only be accessed via CloudFront.

## 4. Security
* **Security Groups:**
* * **ALB SG:** Allows inbound HTTP (80) traffic from the internet.
  * **EC2 SG:** Restricts inbound traffic, allowing connections only from the ALB Security Group.
* **IAM Roles:** EC2 instances are assigned an Instance Profile with policies granting read access to the Elastic Container Registry (ECR) to pull Docker images securely without hardcoded credentials.
