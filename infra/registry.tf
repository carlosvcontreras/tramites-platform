resource "google_artifact_registry_repository" "apps" {
  location      = var.region
  repository_id = "tramites"
  format        = "DOCKER"
  description   = "Imágenes de tramites-api"

  # Un tag (ej. el SHA del commit) no se puede sobrescribir: lo que se probó es lo que corre.
  docker_config {
    immutable_tags = true
  }

  depends_on = [google_project_service.apis]
}
