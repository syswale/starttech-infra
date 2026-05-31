variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "starttech"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ecr_image_uri" {
  description = "The full URI of your backend Docker image"
  type        = string
}

variable "jwt_secret" {
  description = "Secret key for JWT authentication"
  type        = string
  sensitive   = true
}