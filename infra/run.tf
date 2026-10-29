locals {
  # Tope de gasto: máximo de instancias, igual para el servicio y para cada revisión.
  max_instances = 3
}

resource "google_cloud_run_v2_service" "api" {
  name     = "tramites-api"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  # Si es true, terraform destroy no puede borrar el servicio.
  deletion_protection = false

  # Tope del servicio completo (todas las revisiones). La consola de Cloud Run
  # edita este valor, por eso se declara: así el drift lo vigila.
  scaling {
    max_instance_count = local.max_instances
  }

  template {
    service_account = google_service_account.runtime.email

    # Tope por revisión. Escala a 0 sin tráfico (costo casi cero en dev).
    scaling {
      min_instance_count = 0
      max_instance_count = local.max_instances
    }

    containers {
      # Imagen de ejemplo de Google, solo para la primera creación.
      # Después la cambia el pipeline (ver lifecycle abajo).
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        cpu_idle = true # solo se cobra CPU mientras atiende requests
      }

      # API_KEY llega como variable de entorno, leída de Secret Manager al arrancar.
      # Versión FIJA (no "latest"): rotar = agregar versión nueva + PR que cambia este número.
      # Así cada revisión sabe qué llave usa, el rollback es exacto y el drift detecta cambios manuales.
      env {
        name = "API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.api_key.secret_id
            version = "1"
          }
        }
      }
    }
  }

  lifecycle {
    # Terraform es dueño de la "forma" del servicio; el pipeline es dueño de la imagen.
    # Sin esto, cada deploy se vería como drift y un apply regresaría a la imagen de ejemplo.
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version,
    ]
  }

  depends_on = [google_secret_manager_secret_iam_member.runtime_access]
}

# Servicio público para ciudadanos: cualquiera puede invocarlo.
resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.api.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
