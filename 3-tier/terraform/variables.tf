# This is where on our local disk the service account key is for the SA that terraform will use to create infra.
variable "terraform-sa-json-path" {}

# This is where we will instantiate things
variable "project_id" {
  type = string
  default = "test-project"
}

variable target_region {
  default = "us-east1"
}

variable target_zone {
  default = "us-east1-c"
}

variable "network_name" {
  default = "test-subnetwork"
}

variable "network_cidr" {
  default = "10.2.0.0/16"
}

variable "name" {
  description = "Name prefix for the nodes"
  default     = "tf-custom"
}
