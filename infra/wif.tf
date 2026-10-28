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

  # Sin esto, cualquier repo de GitHub podría presentar un token a este pool.
  attribute_condition = "assertion.repository == '${var.github_repo}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

locals {
  # Solo los workflows que corren en la rama main de NUESTRO repo.
  # Un PR o una rama cualquiera no puede usar estas SAs.
  github_main = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/subject/repo:${var.github_repo}:ref:refs/heads/main"
}

resource "google_service_account_iam_member" "deployer_wif" {
  service_account_id = google_service_account.ci_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.github_main
}

resource "google_service_account_iam_member" "drift_wif" {
  service_account_id = google_service_account.ci_drift.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.github_main
}
