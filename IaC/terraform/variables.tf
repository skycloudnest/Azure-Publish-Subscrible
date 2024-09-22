variable "env" {
  description = "Name of environment - will be part of resources names"
}

variable "location" {
  default     = "westeurope"
  description = "azure region where resources will be created"
}

variable "project_prefix" {
  default     = "ps-model"
  description = "Project prefix"
}

variable "workspace_directory" {
  description = "The local path to a workspace directory"
  type        = string
}

variable "function_project_name" {
  description = "The FunctionApp project name"
  type        = string
}