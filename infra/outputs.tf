output "service_url" {
  value = google_cloud_run_v2_service.api.uri
}

output "image_repo" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.apps.repository_id}/tramites-api"
}

# Estos valores van como "Variables" (no secretos) en GitHub.
output "wif_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}

output "deployer_sa" {
  value = google_service_account.ci_deployer.email
}

output "drift_sa" {
  value = google_service_account.ci_drift.email
}
