# Solo el "contenedor" del secreto. El VALOR se agrega con gcloud (README, paso 4),
# así nunca queda en el código ni en el estado de Terraform.
resource "google_secret_manager_secret" "api_key" {
  secret_id = "api-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

# La app (su SA de runtime) solo puede LEER este secreto, ninguno más.
resource "google_secret_manager_secret_iam_member" "runtime_access" {
  secret_id = google_secret_manager_secret.api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.runtime.email}"
}
