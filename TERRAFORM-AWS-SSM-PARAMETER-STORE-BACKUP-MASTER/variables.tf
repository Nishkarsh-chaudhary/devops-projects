variable "aws_region" {
  description = "the aws region things are created in "
}

variable "namespace" {
  description = "Project naming for resources"
}

variable "environment" {
  description = "Environment name"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to be invoked"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to be invoked"
  type        = string
}