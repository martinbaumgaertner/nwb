variable "project_id" {
  default     = "baeumchen-sbx"
  type        = string
  description = "The ID of the GCP project."
}

variable "project_number" {
  default     = "370943352356"
  type        = string
  description = "The project number of the GCP project."
}

variable "region" {
  default     = "europe-west1"
  type        = string
  description = "The region where resources will be deployed."
}

variable "zone" {
  default     = "europe-west1-b"
  type        = string
  description = "The zone where resources will be deployed."
}
