variable "target_region" { default = "us-east1" }
variable "network_cidr" { type = string }
variable "network_name" {type = string }
variable "name_prefix" { type = string }

resource "google_compute_network" "default" {
  name                    = "var.network_name"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name                     = "var.network_name"
  ip_cidr_range            = "var.network_cidr"
  network                  = "google_compute_network.default.self_link"
  region                   = "var.target_region"
  private_ip_google_access = true
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.name_prefix}-ssh"
  network = "google_compute_subnetwork.default.name"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["${var.name_prefix}-ssh"]
}

output "subnetwork" { value = google_compute_subnetwork.default.name }
