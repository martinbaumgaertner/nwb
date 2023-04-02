resource "google_pubsub_topic" "trigger_topic" {
  name = "nwb-api-trigger-topic"
}

resource "google_cloud_scheduler_job" "scheduler" {
  name        = "nwb-api-trigger"
  region      = var.region
  description = "Trigger Cloud Function every 6 hours"

  pubsub_target {
    topic_name = google_pubsub_topic.trigger_topic.id
    data       = "eyJtZXNzYWdlIjogIkhlbGxvLCBXb3JsZCF9"
  }

  schedule  = "0 */6 * * *"
  time_zone = "UTC"
}

resource "google_service_account" "function_sa" {
  account_id   = "api-sa"
  display_name = "Service Account for the NWB API"
}

resource "google_project_iam_member" "function_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "google_project_iam_member" "storage_object_creator" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}
