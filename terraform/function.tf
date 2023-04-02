# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "../src"
  output_path = "./tmp/function.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "zip" {
  source       = data.archive_file.source.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "src-${data.archive_file.source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name

  # Dependencies are automatically inferred so these lines can be deleted
  depends_on = [
    google_storage_bucket.function_bucket, # declared in `storage.tf`
    data.archive_file.source
  ]
}

# Create the Cloud function triggered by a `Finalize` event on the bucket
resource "google_cloudfunctions_function" "function" {
  name                  = "nwb-api"
  runtime               = "python39"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.zip.name
  entry_point           = "main"

  # Assign the created Service Account to the Cloud Function
  service_account_email = google_service_account.function_sa.email

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.trigger_topic.id
  }

  # Set the maximum number of instances to 1
  max_instances = 1

  depends_on = [
    google_storage_bucket.function_bucket,
    google_storage_bucket_object.zip,
    google_pubsub_topic.trigger_topic
  ]
}



