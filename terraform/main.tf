provider "google" {
  project = "sachin-k8s"
  region  = "asia-east2"
  zone    = "asia-east2-b"
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "minimal-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "minimal-subnet"
  network       = google_compute_network.vpc.id
  region        = "asia-east2"
  ip_cidr_range = "10.0.0.0/24"
}

# GKE Cluster - Minimal Configuration
resource "google_container_cluster" "minimal_cluster" {
  name     = "minimal-cluster"
  location = "asia-east2-a"

  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count        = 1

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  # Minimal cluster configuration
  networking_mode = "VPC_NATIVE"
  
  # Minimal addons
  addons_config {
    horizontal_pod_autoscaling {
      disabled = true
    }
    http_load_balancing {
      disabled = true
    }
  }

  # Adjusted IP allocation
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "192.168.0.0/16"
    services_ipv4_cidr_block = "172.16.0.0/16"
  }
}

# Minimal Node Pool - Smallest Possible Configuration
resource "google_container_node_pool" "minimal_nodes" {
  name       = "minimal-node-pool"
  location   = "asia-east2-a"
  cluster    = google_container_cluster.minimal_cluster.name
  
  node_count = 1

  node_config {
    machine_type = "e2-micro"  # Smallest and cheapest machine type
    disk_type    = "pd-standard"
    disk_size_gb = 10

    # Minimal OAuth scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }

  # Minimal management
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Optional: Firewall Rule for Internal Communication
resource "google_compute_firewall" "allow_internal" {
  name    = "minimal-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/24"]
}