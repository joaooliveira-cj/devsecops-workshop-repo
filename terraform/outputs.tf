output "bucket_name" {
  description = "Name of the storage bucket"
  value       = google_storage_bucket.insecure_bucket.name
}

output "bucket_url" {
  description = "URL of the storage bucket"
  value       = google_storage_bucket.insecure_bucket.url
}

output "instance_name" {
  description = "Name of the compute instance"
  value       = google_compute_instance.insecure_instance.name
}

output "database_name" {
  description = "Name of the database instance"
  value       = google_sql_database_instance.insecure_db.name
}

# FIXED: Removed database_public_ip output as DB no longer has public IP
output "database_connection_name" {
  description = "Connection name for the database instance (use with Cloud SQL Proxy)"
  value       = google_sql_database_instance.insecure_db.connection_name
}

output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.insecure_sa.email
  sensitive   = true
}
