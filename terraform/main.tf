terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.59.0"
    }
  }

  # With this backend configuration we are telling Terraform that the
  # created state should be saved in some Google Cloud Bucket with some prefix
  backend "gcs" {
    bucket = "baeumchen-state-files"
    prefix = "sbx/nwb-api"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
