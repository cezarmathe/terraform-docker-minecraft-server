# terraform-docker-minecraft - outputs.tf

output "this_uuid" {
  description = "Uuid used in the names of some of the resources."
  value       = random_uuid.this.result
}

output "this_container_name" {
  description = "Uuid used in the names of some of the resources."
  value       = local.container_name
}

output "this_volume_name" {
  description = "Uuid used in the names of some of the resources."
  value       = local.volume_name
}

output "this_network_data" {
  description = "Network data of the container."
  value       = docker_container.this.network_data
}
