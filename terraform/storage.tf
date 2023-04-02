resource "google_storage_bucket" "function_bucket" {
  name     = "nwb_api_function_bucket"
  location = var.region
}

resource "google_storage_bucket" "input_bucket" {
  name     = "nwb_api_input"
  location = var.region
}
