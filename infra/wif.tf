# Workload Identity Federation: GitHub Actions entra a GCP sin llaves JSON.
# GitHub emite un token OIDC de corta vida por job; GCP lo canjea por un token de la SA.

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions"

  depends_on = [google_project_service.apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  # Candado 1: solo tokens de NUESTRO repo y de la rama main.
  # Se filtra por claims explícitos (repository, ref) y no por el formato de "sub",
  # que GitHub puede cambiar (por ejemplo, el subject inmutable con IDs numéricos).
  attribute_condition = "assertion.repository == '${var.github_repo}' && assertion.ref == 'refs/heads/main'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

locals {
  # Candado 2: las SAs solo aceptan identidades de nuestro repo 
  github_repo_principals = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}

resource "google_service_account_iam_member" "deployer_wif" {
  service_account_id = google_service_account.ci_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.github_repo_principals
}

resource "google_service_account_iam_member" "drift_wif" {
  service_account_id = google_service_account.ci_drift.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.github_repo_principals
}
