# SECURE - Workshop demonstration - secure version

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "workshop-project-12345"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-west1-b"
}

variable "machine_type" {
  description = "Machine type for compute instances"
  type        = string
  default     = "e2-medium"
}

# FIXED: Password removed from code
variable "db_password" {
  description = "Database root password (provide via GitHub Secrets or Secret Manager)"
  type        = string
  sensitive   = true
  # No default value - must be provided securely via:
  # - GitHub Secrets in CI/CD
  # - GCP Secret Manager for runtime
}

# FIXED: API key removed from code
variable "api_key" {
  description = "API Key for external service (provide via GitHub Secrets or Secret Manager)"
  type        = string
  sensitive   = true
  # No default value - must be provided securely via:
  # - GitHub Secrets in CI/CD
  # - GCP Secret Manager for runtime
}
