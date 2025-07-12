terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.43.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
