variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región de Cloud Run y Artifact Registry"
  type        = string
  default     = "us-central1"
}

variable "billing_account" {
  description = "ID de la cuenta de facturación (XXXXXX-XXXXXX-XXXXXX), para el budget"
  type        = string
}

variable "github_repo" {
  description = "Repositorio de GitHub en formato owner/repo. Solo él puede usar WIF."
  type        = string
}

variable "state_bucket" {
  description = "Bucket de GCS donde vive el estado de Terraform (creado con gcloud)"
  type        = string
}
