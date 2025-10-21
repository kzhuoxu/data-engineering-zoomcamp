terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.7.0"
    }
  }
}

provider "google" {
  # Credentials only needs to be set if you do not have the GOOGLE_APPLICATION_CREDENTIALS set
  #  credentials = 
  project = "rock-strength-474020-j5"
  region  = "us-central1"
}



resource "google_storage_bucket" "data-lake-bucket" {
  name     = "rock-strength-474020-j5-terra-bucket"
  location = "US"

  # Optional, but recommended settings:
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30 // days
    }
  }

  force_destroy = true
}


resource "google_bigquery_dataset" "dataset" {
  dataset_id = "demo_dataset"
  project    = "rock-strength-474020-j5"
  location   = "US"
}