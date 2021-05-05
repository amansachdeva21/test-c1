# ========================================
# TABLE OF CONTENTS
# ========================================

resource "google_compute_global_forwarding_rule" "https" {
  project    = var.project_id
  name       = "${var.name_prefix}-${var.name}-https"
  target     = google_compute_target_https_proxy.default.self_link
  ip_address = google_compute_global_address.default.address
  port_range = var.port_range
  depends_on = [google_compute_global_address.default]
}

resource "google_compute_target_https_proxy" "default" {
  project          = var.project_id
  name             = "${var.name_prefix}-${var.name}-https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates =  ["/tmp/key.pem"]
  quic_override    = "NONE"
}

resource "google_compute_url_map" "url_map" {
  project         = var.project_id
  name            = "${var.name_prefix}-${var.name}"
  default_service = element(google_compute_backend_service.default.*.self_link, 0)
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name            = "allpaths"
    default_service = element(google_compute_backend_service.default.*.self_link, 0)
    path_rule {
      paths   = ["/"]
      service = element(google_compute_backend_service.default.*.self_link, 0)
    }
  }
}

resource "google_compute_backend_service" "default" {
  project     = var.project_id
  name        = "${var.name_prefix}-${var.name}-bs"
  port_name   = var.port_name
  protocol    = var.protocol
  timeout_sec = var.backend_timeout_sec
  enable_cdn  = false
  count       = 1

  backend  {
    group                 = var.instance_group
    balancing_mode        = var.balancing_mode
    max_rate_per_instance = 100
  }

  health_checks                   = [element(compact(concat(google_compute_health_check.default.*.self_link, google_compute_health_check.http_hc.*.self_link)), 0)]
  session_affinity                = var.session_affinity
  connection_draining_timeout_sec = var.draining_timeout_sec
}

resource "google_compute_health_check" "default" {
  count               = var.https_hc ? 1 :0
  name                = "${var.name_prefix}-${var.name}-hc"
  project             = var.project_id
  check_interval_sec  = var.check_interval_sec
  timeout_sec         = var.hc_timeout_sec
  healthy_threshold   = var.hc_healthy_threshold
  unhealthy_threshold = var.hc_unhealthy_threshold
  https_health_check {
    request_path = var.hc_request_path
    port         = var.hc_port
  }
}

resource "google_compute_health_check" "http_hc" {
  count               = var.http_hc ? 1 :0
  name                = "${var.name_prefix}-${var.name}-hc"
  project             = var.project_id
  check_interval_sec  = var.check_interval_sec
  timeout_sec         = var.hc_timeout_sec
  healthy_threshold   = var.hc_healthy_threshold
  unhealthy_threshold = var.hc_unhealthy_threshold
  http_health_check {
    request_path = var.hc_request_path
    port         = var.hc_port
  }
}

# ========================================
# IP ADDRESSES
# ========================================
resource "google_compute_global_address" "default" {
  project = var.project_id
  ip_version = "IPV4"
  name = "${var.name_prefix}-${var.name}-address"
}

# ========================================
# OUTPUTS
# ========================================

locals {
  dns_extension = var.use_base_domain ? "" : (var.name == "" ? "" : "-${var.name}")
}

output o {
  value = {
    core_glb = {
      name = "${var.name_prefix}-${var.name}"
      backend_services = google_compute_backend_service.default.*.self_link
      external_ip4 = google_compute_global_address.default.address
    }
  }
}

output "ip_address" {
  value = google_compute_global_address.default.address
}
