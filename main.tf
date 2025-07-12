data "google_compute_image" "image" {
  for_each = local.image_filter

  family = each.value.family
  project = lookup(
    {
      "debian-11"       = "debian-cloud"
      "debian-12"       = "debian-cloud"
      "ubuntu-2004-lts" = "ubuntu-os-cloud"
      "ubuntu-2204-lts" = "ubuntu-os-cloud"
      "rocky-linux-8"   = "rocky-linux-cloud"
      "rocky-linux-9"   = "rocky-linux-cloud"
      "centos-7"        = "centos-cloud"
      "cos-stable"      = "cos-cloud"
    },
    each.value.family,
    "debian-cloud" # fallback
  )
  most_recent = true
}

data "google_compute_subnetwork" "public" {
  project = var.project
  region  = var.region
  name    = var.public_subnet_name
}

data "google_compute_subnetwork" "private" {
  project = var.project
  region  = var.region
  name    = var.private_subnet_name
}

resource "tls_private_key" "generated_ssh" {
  count     = var.create_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_disk" "primary" {
  for_each                  = local.attached_disk_enabled_instances
  name                      = "${each.key}-pers-disk"
  type                      = "pd-ssd"
  zone                      = var.zone
  size                      = each.value.disk_size_gb
  physical_block_size_bytes = 4096
}

resource "google_compute_attached_disk" "default" {
  for_each = local.attached_disk_enabled_instances
  disk     = google_compute_disk.primary[each.key].id
  instance = google_compute_instance.instance[each.key].id
}


resource "google_compute_instance" "instance" {
  for_each     = local.instances_map
  name         = each.key
  machine_type = each.value.machine_type
  zone         = var.zone

  tags                      = each.value.tags
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = data.google_compute_image.image[each.key].self_link
      type  = each.value.boot_disk_type
      size  = each.value.boot_disk_size_gb
    }
  }

  // Scratch disk
  dynamic "scratch_disk" {
    for_each = each.value.scratch_disk ? [1] : []
    content {
      interface = each.value.scratch_disk_interface
    }
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = local.subnet_ids[each.value.subnet_type]
    dynamic "access_config" {
      for_each = each.value.subnet_type == "public" ? [1] : []
      content {
        nat_ip = null
      }
    }
  }

  dynamic "service_account" {
    for_each = each.value.service_account_email != null ? [1] : []
    content {
      email  = each.value.service_account_email
      scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }
  }
  metadata = merge(
    each.value.metadata,
    var.create_ssh_key ? {
      "ssh-keys" = local.ssh_key_entry
    } : {}
  )
  metadata_startup_script = each.value.metadata_startup_script
}
