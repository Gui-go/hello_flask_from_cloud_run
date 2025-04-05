terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "default" {
  name     = "my-app-service"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/my-app-image:${var.image_tag}"
        ports {
          container_port = 8080
        }
      }
    }
  }

  traffic {
    latest_revision = true
    percent         = 100
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name

  policy_data = <<POLICY
{
  "bindings": [
    {
      "members": [
        "allUsers"
      ],
      "role": "roles/run.invoker"
    }
  ]
}
POLICY
}

output "service_url" {
  value = google_cloud_run_service.default.status[0].url
}