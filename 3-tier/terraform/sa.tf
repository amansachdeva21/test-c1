resource "google_service_account" "test_sa" {
  project      = var.project_id
  account_id   = "test-sa"
  display_name = "TestService Account"
}

# owner access
resource "google_project_iam_member" "project_owner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.test_sa.email}"
}
