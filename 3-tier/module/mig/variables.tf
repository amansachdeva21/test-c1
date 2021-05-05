variable name {}

variable short_name {}

variable description {
  default = ""
}

variable project_id {
  default = ""
}

variable region {}

variable zone {}

variable create_target_pool {
  default = false
}

variable tag_name {}

variable cluster_size {}

variable rolling_update_policy {
  #type = list

  default = {
    minimal_action        = "REPLACE"
    type                  = "OPPORTUNISTIC"
    max_unavailable_fixed = 0
    max_surge_fixed       = 1
    min_ready_sec         = 120
  }
}

variable named_ports {
  type = list(object({
    name = string
    port = number
  }))
  default = []
}

variable machine_type {}

variable source_image {}

variable startup_script {}

variable metadata_key_name {
  default = "cluster-size"
}

variable custom_metadata {
  type    = map
  default = {}
}

variable root_volume_disk_size {
  default = 30
}

variable root_volume_disk_type {
  default = "pd-standard"
}

variable network_project {
  default = ""
}

variable subnetwork_name {
  default = "default"
}

variable tags {
  type    = list
  default = []
}

variable service_account_scopes {
  type    = list
  default = []
}

variable service_account_email {
  default = ""
}
