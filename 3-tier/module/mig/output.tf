output "o" {
  value = {
    instance_group_manager  = google_compute_instance_group_manager.server_group
    instance_template       = google_compute_instance_template.template
    pool                    = google_compute_target_pool.pool
  }
}
