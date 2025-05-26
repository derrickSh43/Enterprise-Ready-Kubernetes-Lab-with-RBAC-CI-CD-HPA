terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.28.0"
    }
  }
}

provider "google" {
  credentials = file("D:/GKE_Lab/terraform-sa-key.json")
  project     = var.project_id
  region      = var.region
}

# VPC
resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = "gke-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_firewall" "allow-egress-https" {
  name        = "allow-egress-https"
  network     = "gke-vpc"
  description = "Allow egress to HTTPS for image pulls"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  priority           = 1000

}

# Subnet with larger secondary ranges
resource "google_compute_subnetwork" "gke_subnet" {
  name                     = "gke-subnet-central1"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  ip_cidr_range            = "10.230.0.0/16"
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pods-central1"
    ip_cidr_range = "192.168.0.0/20"
  }
  secondary_ip_range {
    range_name    = "gke-services-central1"
    ip_cidr_range = "192.168.16.0/24"
  }
}

resource "google_compute_router" "gke_router" {
  name    = "gke-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "gke_nat" {
  name                               = "gke-nat"
  router                             = google_compute_router.gke_router.name
  region                             = google_compute_router.gke_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Service Account for GKE nodes
resource "google_service_account" "gke_nodes" {
  project      = var.project_id
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

# IAM Roles for Service Account
resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset([
    "roles/compute.instanceAdmin.v1",
    "roles/container.nodeServiceAccount",
    "roles/storage.objectViewer",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# GKE Cluster (zonal, us-central1-a)
resource "google_container_cluster" "gke_us_central1" {
  name                      = "gke-central1-cluster"
  project                   = var.project_id
  location                  = "us-central1-a"
  default_max_pods_per_node = 32

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods-central1"
    services_secondary_range_name = "gke-services-central1"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.10.0/28"
  }

  release_channel {
    channel = "REGULAR"
  }

  deletion_protection = false

  depends_on = [google_compute_subnetwork.gke_subnet]
}

# Node Pool (3 preemptible e2-medium nodes)
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "primary-node-pool"
  project    = var.project_id
  cluster    = google_container_cluster.gke_us_central1.id
  node_count = 3

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    service_account = google_service_account.gke_nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    tags = ["gke-node", "cluster-central1"]
  }

  depends_on = [google_container_cluster.gke_us_central1]
}

terraform {
  backend "s3" {
    bucket = "myterraformbackendclss6"
    key    = "gke-central1-cluster/terraform.tfstate"
    region = "us-east-1"
  }
}