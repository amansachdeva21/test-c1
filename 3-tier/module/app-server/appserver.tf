variable "vpc_subnetwork" { type = string }
variable "target_region" { default = "us-east1" }
variable "target_zone" { default = "us-east1-c" }
variable "project_id" {type = string }
variable "name_prefix" { type = string }
variable "vpc_project" { type = string }
variable "vpc_name" { type = string }

variable "disk_image" {}
variable "service_account" {}

# ========================================
# app server MIG
# ========================================

module app_server_mig {
  source = "../mig"
  project_id = var.project_id
  region = var.target_region
  zone = var.target_zone
  tag_name = "${var.name_prefix}-app-server"
  cluster_size = 1 #auto scaler, choose numer of instances you want to make

  create_target_pool = true
  named_ports = [
    {
      name = "http"
      port = 8080
    }
  ]

  source_image = var.disk_image.self_link
  short_name = "${var.name_prefix}-app-mig"
  machine_type = "n1-standard-8"
  startup_script = "echo hi > /test.txt"
  name = "${var.name_prefix}-app-mig"
  service_account_email = var.service_account
  network_project = var.vpc_project
  subnetwork_name = var.vpc_subnetwork
  tags = ["${var.name_prefix}-ssh"]
}

# ========================================
# ILB for app server, which is required
# ========================================
