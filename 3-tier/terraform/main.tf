# ==========
# DISK IMAGE to be used.
# ==========

data "google_compute_image" "rhel" {
  family = "rhel-7"
  project = var.project_id
}

module "vpc" {
  source         = "../module/vpc"
  network_name   = var.network_name
  network_cidr   = var.network_cidr
  target_region  = var.target_region
  name_prefix    = var.name
}

module "web_server" {
  source          = "../module/web-server"
  project_id      = var.project_id
  name_prefix     = var.name

  vpc_project     = var.project_id
  vpc_name        = module.vpc.subnetwork
  vpc_subnetwork  = module.vpc.subnetwork

  target_region   = var.target_region
  target_zone     = var.target_zone
  disk_image      = data.google_compute_image.rhel
  service_account = google_service_account.test_sa.email
}

# just creating MIG, ILB needs to be created
module "app_server" {
  source = "../module/app-server"
  project_id      = var.project_id
  name_prefix     = var.name

  vpc_project     = var.project_id
  vpc_name        = module.vpc.subnetwork
  vpc_subnetwork  = module.vpc.subnetwork

  target_region   = var.target_region
  target_zone     = var.target_zone
  disk_image      = data.google_compute_image.rhel
  service_account = google_service_account.test_sa.email
}

module "db" {
  source = "../module/db"
  project_id            = var.project_id
  name_prefix           = var.name

  vpc_project           = var.project_id
  vpc_name              = module.vpc.subnetwork
  vpc_subnetwork        = module.vpc.subnetwork

  target_region         = var.target_region
  target_zone           = var.target_zone

  db_user_password = "test" # ideally it should be stored in secure palce like vault
}
