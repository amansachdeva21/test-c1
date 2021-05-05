# ==========
# STANDARD VARIABLES
# ==========

variable "project_id" {type = string }
variable "name_prefix" { type = string }
variable "vpc_project" { type = string }
variable "vpc_name" { type = string }
variable "vpc_subnetwork" { type = string }
variable "target_region" { default = "us-east1" }
variable "target_zone" { default = "us-east1-c" }
variable name { type = string }

variable hc_healthy_threshold {
  default     = 1
}
variable hc_unhealthy_threshold {
  default     = 10
}
variable hc_request_path {
  default     = "/"
}
variable hc_port {
  type = number
  default = 80
}
variable port_name {
  type = string
  default = "https"
}
variable port_range {
  default     = 443
}
variable hc_timeout_sec {
  default     = 5
}
variable backend_timeout_sec {
  default     = 180
}
variable check_interval_sec {
  default     = 10
}
variable balancing_mode {
  default     = "UTILIZATION"
}
variable max_rate_per_instance {
  type        = string
  default     = null
}
variable session_affinity {
  default     = "NONE"
}
variable draining_timeout_sec {
  default     = 120
}
variable instance_group {
  type = string
}
variable protocol {
  default     = "HTTPS"
}
variable https_hc {
  type = bool
  default = false
}

variable http_hc {
  type = bool
  default = false
}

variable use_base_domain { default = false }
variable iap { default = 0 }
