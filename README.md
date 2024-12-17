1. Terraform Code

1. Provider Configuration

This sets up the GCP provider for Terraform:

provider "google" {
  project = "sachin-k8s"   # GCP project name
  region  = "asia-east2"   # Default region
  zone    = "asia-east2-b" # Default zone
}

2. VPC Network

Define a custom VPC network with no auto-generated subnets:

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "minimal-vpc"
  auto_create_subnetworks = false
}

3. Subnet

Create a subnet under the VPC with an IP range:

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "minimal-subnet"
  network       = google_compute_network.vpc.id
  region        = "asia-east2"
  ip_cidr_range = "10.0.0.0/24"
}

4. GKE Cluster

Configure the GKE cluster with minimal settings:

# GKE Cluster - Minimal Configuration
resource "google_container_cluster" "minimal_cluster" {
  name     = "minimal-cluster"
  location = "asia-east2-a"

  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1

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

5. GKE Node Pool

Add a minimal node pool with the smallest machine configuration:

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


6. Firewall Rule (Optional)

Allow internal communication between resources within the subnet:

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


2. High-Level Architecture Design and Summary

Task 1: Design a High-Level Architecture Diagram


VPC: Custom VPC with 2 subnets (General and CPU workloads).
CloudSQL: Private IP enabled within VPC.
Redis: Deployed in a private subnet.
Firewall: Restrict external access.
VPC Peering: For cross-network communication.

Task 2: Secure the Setup


Use IAM roles for least-privilege access.
Enable private IPs for CloudSQL and Redis.
Restrict firewall rules to internal communication only.

Task 3: Optimize Costs While Maintaining High Availability


Use auto-scaling for GKE node pools.
Deploy across multiple zones.
Use preemptible VMs for non-critical workloads.


3. CI/CD Pipeline Using GitHub Actions

Task 1: Build and Push Docker Image to GCR


name: Terraform Pipeline for React App on GKE

on:
  push:
    branches:
      - main  # Trigger on push to main branch
  pull_request:
    branches:
      - master  # Trigger on PR to master branch

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: "1.4.6"

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply
        run: terraform apply -auto-approve
        env:
          GOOGLE_APPLICATION_CREDENTIALS: ${{ secrets.GCP_SA_KEY }}


Task 2: Deploy the Image Using ArgoCD

Question: Explain how you configure the deployment through ArgoCD.

Use ArgoCD Application CRD to monitor the Git repository.
ArgoCD syncs the new Docker image from GitHub Actions.


4. Troubleshooting Network Timeout

Task 1: Explain Your Troubleshooting Approach


Check Logs: Use kubectl logs to identify errors.
Verify Connectivity: Test connectivity to CloudSQL using

kubectl exec -it <pod-name> -- curl http://<cloudsql-ip>

Check Network Policies: Ensure GKE pods can communicate with CloudSQL.
GCP VPC Logs: Use VPC flow logs to identify blocked traffic.


Task 2: Tools and Steps to Resolve the Issue


Tools:
kubectl for debugging.
GCP Monitoring and VPC logs for network flow analysis.
Steps:

Ensure CloudSQL is using private IPs.
Update firewall rules to allow necessary traffic.
Implement readiness and liveness probes.
Enable monitoring and alerting to detect issues early
![Uploading image.png…]()
