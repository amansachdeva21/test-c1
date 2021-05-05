locals {
  network_project = var.network_project == "" ? var.project_id : var.network_project
}

data "google_compute_subnetwork" "subnet" {
  project = local.network_project
  name    = var.subnetwork_name
  region  = var.region
}

resource "google_compute_target_pool" "pool" {
  count = var.create_target_pool? 1 : 0
  name = "${var.name}-pool"
  project = var.project_id
  region = var.region
}

resource "google_compute_instance_group_manager" "server_group" {
  project = var.project_id

  provider = google-beta
  name     = "${var.name}-vm-group"
  zone     = var.zone

  base_instance_name = "${var.name}-vm"

  version {
    name              = "default"
    instance_template = google_compute_instance_template.template.self_link
  }

  dynamic named_port {
    iterator = e
    for_each =  var.named_ports
    content {
      name = e.value.name
      port = e.value.port
    }
  }

  target_pools = var.create_target_pool? [google_compute_target_pool.pool[0].id] : []
  #update_strategy = "${var.instance_group_update_strategy}"
  target_size = var.cluster_size
  depends_on  = [google_compute_instance_template.template]


  update_policy {
    minimal_action = var.rolling_update_policy.minimal_action
    type = var.rolling_update_policy.type
    max_unavailable_fixed = var.rolling_update_policy.max_unavailable_fixed
    max_surge_fixed =var.rolling_update_policy.max_surge_fixed
    min_ready_sec = var.rolling_update_policy.min_ready_sec
  }

  wait_for_instances = true
}

resource "google_compute_instance_template" "template" {
  project = var.project_id
  region  = var.region

  name_prefix = "${var.short_name}-vm-template-"
  description = var.description

  instance_description = var.description
  machine_type         = var.machine_type
  can_ip_forward       = false

  tags                    = concat(list(var.tag_name), var.tags)
  metadata_startup_script = var.startup_script
  metadata                = merge(map(var.metadata_key_name, var.cluster_size), var.custom_metadata)

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  disk {
    boot         = true
    auto_delete  = true
    source_image = var.source_image
    disk_size_gb = var.root_volume_disk_size
    disk_type    = var.root_volume_disk_type
  }

  network_interface {
    subnetwork_project = local.network_project
    subnetwork         = data.google_compute_subnetwork.subnet.name
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
