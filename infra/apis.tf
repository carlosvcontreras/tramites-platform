locals {
  apis = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com", # WIF: canjear el token de GitHub por uno de la SA
    "sts.googleapis.com",            # WIF: Security Token Service
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com", # permisos IAM sobre la cuenta de facturación (ci-drift)
    "cloudresourcemanager.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.apis)
  service  = each.value

  # Al hacer destroy no se apagan las APIs (apagarlas puede romper otras cosas del proyecto).
  disable_on_destroy = false
}
