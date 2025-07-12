locals {
  instances_map = {
    for inst in var.instances :
    inst.name => {
      machine_type            = inst.machine_type
      attached_disk           = inst.attached_disk != null ? inst.attached_disk : false
      attached_disk_size      = try(inst.attached_disk_size, 100)
      scratch_disk            = inst.scratch_disk != null ? inst.scratch_disk : true
      scratch_disk_interface  = try(inst.scratch_disk_interface, "NVME")
      subnet_type             = inst.subnet_type
      os_family               = try(inst.os_family, "debian-11")
      os_version              = try(inst.os_version, "debian-11-bullseye-")
      tags                    = inst.tags
      metadata                = inst.metadata != null ? inst.metadata : {}
      metadata_startup_script = inst.metadata_startup_script != null ? inst.metadata_startup_script : null
      boot_disk_type          = try(inst.boot_disk_type, "pd-balanced")
      boot_disk_size_gb       = try(inst.boot_disk_size_gb, 20)
      service_account_email   = try(inst.service_account_email, null)
    }
  }
  attached_disk_enabled_instances = {
    for name, inst in local.instances_map :
    name => {
      instance_details = inst
      disk_size_gb     = inst.attached_disk_size
    }
    if inst.attached_disk
  }
  subnet_ids = {
    public  = data.google_compute_subnetwork.public.subnetwork_id
    private = data.google_compute_subnetwork.private.subnetwork_id
  }

  image_filter = {
    for name, inst in local.instances_map :
    name => {
      family  = inst.os_family
      version = inst.os_version
    }
  }
  ssh_key_entry = var.create_ssh_key ? "${var.ssh_username}:${tls_private_key.generated_ssh[0].public_key_openssh}" : null
}
