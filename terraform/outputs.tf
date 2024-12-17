output "cluster_name" {
  value = google_container_cluster.minimal_cluster.name
}

output "cluster_endpoint" {
  value = google_container_cluster.minimal_cluster.endpoint
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.minimal_cluster.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_location" {
  value = google_container_cluster.minimal_cluster.location
}

output "node_pool_name" {
  value = google_container_node_pool.minimal_nodes.name
}