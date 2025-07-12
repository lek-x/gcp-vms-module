
output "instance_id" {

  description = "ID of instance"
  value = {
    for instance, id in google_compute_instance.instance :
    instance => id.id
  }
}


output "generated_private_key_pem" {
  value     = var.create_ssh_key ? tls_private_key.generated_ssh[0].private_key_pem : null
  sensitive = true
}


output "ephemeral_vm_public_ip" {
  description = "The ephemeral public IP address of the VM"
  value = {
    for instance, ip in google_compute_instance.instance :
    instance => ip.network_interface[0].access_config[0].nat_ip
    if length(ip.network_interface[0].access_config) > 0
  }
}
