variable "environment_name" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "default region to deploy to"
  type        = string
  default     = "us-west-2"
}

variable "ami_size" {
  description = "size of ami to default to"
  type        = string
  default     = "t2.micro"
}

variable "app_name" {
  type        = string
  description = "Friendly name of the app"
  default     = "web-app"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}