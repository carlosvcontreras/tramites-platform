terraform {
  required_version = ">= 1.17.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.8"
    }
  }

  # Estado remoto en GCS. El bucket se pasa en `terraform init -backend-config="bucket=..."`
  # porque el bloque backend no acepta variables. El bucket se crea con gcloud (README, paso 2).
  backend "gcs" {
    prefix = "tramites/infra"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region

  # La API de budgets necesita un "quota project" cuando se usan credenciales de usuario.
  billing_project       = var.project_id
  user_project_override = true
}
