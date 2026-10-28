# Tres identidades, cada una con lo mínimo para su trabajo.

# 1) La app en Cloud Run. Solo lee su secreto (ver secret.tf).
resource "google_service_account" "runtime" {
  account_id   = "tramites-runtime"
  display_name = "tramites-api runtime"
}

# 2) El pipeline de deploy: subir imágenes y crear revisiones de ESTE servicio.
resource "google_service_account" "ci_deployer" {
  account_id   = "ci-deployer"
  display_name = "GitHub Actions - deploy"
}

resource "google_artifact_registry_repository_iam_member" "deployer_push" {
  location   = google_artifact_registry_repository.apps.location
  repository = google_artifact_registry_repository.apps.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.ci_deployer.email}"
}

resource "google_cloud_run_v2_service_iam_member" "deployer_run" {
  name     = google_cloud_run_v2_service.api.name
  location = var.region
  role     = "roles/run.developer"
  member   = "serviceAccount:${google_service_account.ci_deployer.email}"
}

# "actAs": para desplegar una revisión que corre como la SA runtime.
resource "google_service_account_iam_member" "deployer_actas" {
  service_account_id = google_service_account.runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.ci_deployer.email}"
}

# 3) La detección de drift: solo lectura.
resource "google_service_account" "ci_drift" {
  account_id   = "ci-drift"
  display_name = "GitHub Actions - drift (solo lectura)"
}

resource "google_project_iam_member" "drift_viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.ci_drift.email}"
}

# Necesario porque el provider usa el proyecto como "quota project" (versions.tf).
resource "google_project_iam_member" "drift_usage" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.ci_drift.email}"
}

# Leer el estado. Sin permiso de escritura: el plan corre con -lock=false.
resource "google_storage_bucket_iam_member" "drift_state_read" {
  bucket = var.state_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.ci_drift.email}"
}

# Leer el budget (vive en la cuenta de facturación, no en el proyecto).
resource "google_billing_account_iam_member" "drift_billing_read" {
  billing_account_id = var.billing_account
  role               = "roles/billing.viewer"
  member             = "serviceAccount:${google_service_account.ci_drift.email}"
}
