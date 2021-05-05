terraform {
  required_version = ">= 0.13.5"
}

#This is where the terraform state will go.
terraform {
  backend "gcs" {
    bucket = "test-tfstate"
    prefix = "test"
  }
}

provider "google" {
  project     = var.project_id
  credentials = var.terraform-sa-json-path
}

provider "google-beta" {
  project     = var.project_id
  credentials = var.terraform-sa-json-path
}
