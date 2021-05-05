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
# web server MIG
# ========================================

module web_server_mig {
  source = "../mig"
  project_id = var.project_id
  region = var.target_region
  zone = var.target_zone
  tag_name = "${var.name_prefix}-web-server"
  cluster_size = 1 #auto scaler, choose numer of instances you want to make

  startup_script = "echo hi > /test.txt"
  create_target_pool = true
  named_ports = [
    {
      name = "https"
      port = 443
    }
  ]

  source_image = var.disk_image.self_link
  short_name = "${var.name_prefix}-web-mig"
  machine_type = "n1-standard-8"
  name = "${var.name_prefix}-web-mig"
  service_account_email = var.service_account
  network_project = var.vpc_project
  subnetwork_name = var.vpc_subnetwork
  tags = ["${var.name_prefix}-ssh"]
}

# ========================================
# GLB
# ========================================

module "glb" {
  source = "../glb"
  project_id = var.project_id
  name_prefix = var.name_prefix

  vpc_project = var.vpc_project
  vpc_name = var.vpc_name
  vpc_subnetwork = var.vpc_subnetwork

  target_region = var.target_region
  target_zone = var.target_zone

  https_hc = true
  name = "webserver"

  backend_timeout_sec  = 180
  balancing_mode       = "RATE"
  protocol             = "HTTP"
  port_name            = "webserver"
  session_affinity     = "GENERATED_COOKIE"
  draining_timeout_sec = 400
  instance_group  = module.web_server_mig.o.instance_group_manager.instance_group

  hc_port         = 443
  hc_request_path = "/"
}

output "o" {
  value = {
    glb = module.glb.o
    web_s_address = module.glb.ip_address
  }
}

output "web_s_address" { value = module.glb.ip_address }
