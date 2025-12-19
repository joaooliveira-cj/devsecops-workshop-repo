# SECURE - All vulnerabilities fixed
# Workshop demonstration - secure version

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# FIXED: Public bucket - All security issues resolved
resource "google_storage_bucket" "insecure_bucket" {
  name          = "${var.project_id}-insecure-bucket"
  location      = var.region
  force_destroy = true

  # FIXED: Enable uniform bucket-level access (CKV_GCP_29)
  uniform_bucket_level_access = true

  # FIXED: Enable versioning (CKV_GCP_78)
  versioning {
    enabled = true
  }

  # FIXED: Enable access logging (CKV_GCP_62)
  logging {
    log_bucket = "${var.project_id}-insecure-bucket"
  }

  # FIXED: Enforce public access prevention (CKV_GCP_114)
  public_access_prevention = "enforced"

  # FIXED: Use customer-managed encryption key (AVD-GCP-0066)
  encryption {
    default_kms_key_name = "projects/${var.project_id}/locations/${var.region}/keyRings/workshop-keyring/cryptoKeys/workshop-key"
  }
}

# FIXED: Removed public bucket access (AVD-GCP-0001)
# To grant access to specific users, use:
# resource "google_storage_bucket_iam_member" "restricted_access" {
#   bucket = google_storage_bucket.insecure_bucket.name
#   role   = "roles/storage.objectViewer"
#   member = "user:admin@example.com"
# }

# FIXED: SSH restricted to specific IP range or IAP (AVD-GCP-0027)
resource "google_compute_firewall" "allow_restricted_ssh" {
  name    = "allow-restricted-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # SECURE: Use Google Cloud IAP range or specific office IP
  source_ranges = ["35.235.240.0/20"] # Google Cloud IAP
}

# FIXED: Shielded VM enabled with all features
resource "google_compute_instance" "insecure_instance" {
  name         = "insecure-vm-instance"
  machine_type = var.machine_type
  zone         = var.zone

  # FIXED: Enabled all Shielded VM features (AVD-GCP-0067, AVD-GCP-0041, AVD-GCP-0045)
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
    # FIXED: Use customer-managed encryption key (AVD-GCP-0033)
    kms_key_self_link = "projects/${var.project_id}/locations/${var.zone}/keyRings/workshop-keyring/cryptoKeys/workshop-key"
  }

  network_interface {
    network = "default"
  }

  # FIXED: Block project-wide SSH keys and enable OS Login (CKV_GCP_32, CKV_GCP_34)
  metadata = {
    block-project-ssh-keys = "true"
    enable-oslogin         = "TRUE"
  }

  # FIXED: Use least-privilege scopes instead of cloud-platform
  service_account {
    email  = google_service_account.insecure_sa.email
    scopes = ["compute-ro", "storage-ro", "logging-write", "monitoring-write"]
  }
}

# FIXED: Least privilege IAM roles
resource "google_service_account" "insecure_sa" {
  account_id   = "insecure-service-account"
  display_name = "Service Account - Least Privilege"
}

# Use specific roles instead of Editor
resource "google_project_iam_member" "sa_compute_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.insecure_sa.email}"
}

resource "google_project_iam_member" "sa_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.insecure_sa.email}"
}

# FIXED: Database security - All issues resolved
resource "google_sql_database_instance" "insecure_db" {
  name             = "insecure-mysql-instance"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    # FIXED: Enable backups (AVD-GCP-0024)
    backup_configuration {
      enabled = true
    }

    ip_configuration {
      # FIXED: Disabled public IP (AVD-GCP-0017)
      ipv4_enabled = false

      # Note: For private IP access, configure VPC peering:
      # private_network = "projects/${var.project_id}/global/networks/default"

      # FIXED: SSL required for all connections (AVD-GCP-0015)
      ssl_mode = "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
    }
  }

  deletion_protection = false
}

resource "google_sql_user" "insecure_db_user" {
  name     = "root"
  instance = google_sql_database_instance.insecure_db.name
  password = var.db_password
}
