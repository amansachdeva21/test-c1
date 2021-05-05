variable "project_id" {type = string }
variable "name_prefix" { type = string }
variable "vpc_project" { type = string }
variable "vpc_name" { type = string }
variable "vpc_subnetwork" { type = string }
variable "target_region" { default = "us-east1" }
variable "target_zone" { default = "us-east1-c" }

locals {
  db_name = {
  test       = "test_db"
  }
  db_user = {
  test       = "test_user"
  }
}

variable "db_user_password" { type = string }

# ========================================
# DATABASE INSTANCE
# ========================================

resource "google_sql_database_instance" "test_db" {
  provider = google-beta
  project = var.project_id
  name = "${var.name_prefix}-db"
  database_version = "POSTGRES_13"
  region = var.target_region
  deletion_protection = true # this is to be set false if you want to delete the insance on terrafrom destroy

  settings {
    tier = "db-custom-4-15360"
    availability_type = "ZONAL"
    disk_type = "PD_SSD"
    disk_size = "50"
    disk_autoresize = true
    replication_type = ""

    ip_configuration {
      ipv4_enabled = false #public ip is disabled
      private_network = "projects/${var.vpc_project}/global/networks/${var.vpc_name}"
    }

    backup_configuration {
      enabled = false
      start_time = "04:00"
      point_in_time_recovery_enabled = false
      location = "us"
    }

    maintenance_window {
      day = 3
      hour = 3
      update_track = "stable"
    }

  }
  timeouts {
    create = "5m"
    delete = "5m"
    update = "5m"
  }
}

# ========================================
# DATABASE
# ========================================
resource "google_sql_database" "test" {
  for_each = local.db_name
  project = var.project_id
  name = each.value
  instance = google_sql_database_instance.test_db.name

  depends_on = [
    google_sql_database_instance.test_db,
  ]
}

# ========================================
# USER ACCOUNTS
# ========================================
resource "google_sql_user" "test" {
  for_each = local.db_user
  project = var.project_id
  name = each.value
  instance = google_sql_database_instance.test_db.name
  password = var.db_user_password

  depends_on = [
    google_sql_database_instance.test_db,
  ]
}

output "address" {
  value = google_sql_database_instance.test_db.private_ip_address
}
