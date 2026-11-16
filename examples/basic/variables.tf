variable "base_name" {
  type        = string
  description = "Prefijo de nombre para todos los recursos del ejemplo."
  default     = "aifbasic"
}

variable "location" {
  type        = string
  description = "Azure region for the deployment."
  default     = "eastus2"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to apply to all resources."
  default = {
    environment = "dev"
    example     = "basic"
  }
}
