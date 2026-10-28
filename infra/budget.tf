data "google_project" "this" {}

resource "google_billing_budget" "monthly" {
  billing_account = var.billing_account
  display_name    = "tramites - 10 USD"

  budget_filter {
    projects = ["projects/${data.google_project.this.number}"]
    # Con free trial los créditos cubren todo y el gasto se vería en $0.
    # Así la alerta mide el costo real.
    credit_types_treatment = "EXCLUDE_ALL_CREDITS"
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = "10"
    }
  }

  # Correo a los admins de facturación al 50 %, 90 % y 100 %.
  # Ojo: un budget AVISA, no corta el gasto.
  threshold_rules {
    threshold_percent = 0.5
  }
  threshold_rules {
    threshold_percent = 0.9
  }
  threshold_rules {
    threshold_percent = 1.0
  }

  depends_on = [google_project_service.apis]
}
