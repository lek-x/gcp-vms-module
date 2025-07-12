# GCP VM Module

This module creates a Google Cloud Platform (GCP) Virtual instance(s).

## Features

*   Creates instance(s).
*   Configurable machine type, image, and disk size, scratck disk, attached disk.
*   Supports network interfaces and access configurations.
*   Allows for custom metadata and labels.
*   Use service account if present.
*   Creates ssh key if required.

## Requirements
Terraform >= 1.9.8

## Usage

To use this module, include it in your Terraform configuration and provide the required variables.

```terraform
module "gcp-instaces" {
  source  = "git::https://github.com/lek-x/gcp-vms-module.git"

  project   = "your-gcp-project-id"
  regio     = "your-gcp-region"
  zone         = "your-gcp-zone"

  # Current networks
  # see https://github.com/lek-x/gcp-vpc-module.git
  vpc_name     = "your-vpc-name"
  public_subnet_name = "your-public-subnet-name"
  private_subnet_name = "your-private-subnet-name"

  create_ssh_key = true # true or false
  ssh_username = "your-ssh-username if create_ssh_key is true"


  # Instances
  instances = [
    {
      name                    = "my-instance-1"
      machine_type            = "e2-micro"
      os_family               = "rocky-linux-8"
      os_version              = ""
      tags                    = ["instance", "public"]
      attached_disk           = false
      scratch_disk            = true
      scratch_disk_interface  = "NVME"
      boot_disk_type          = "pd-standard"
      boot_disk_size          = 10
      metadata                = { instance = "first" }
      metadata_startup_script = "echo hi > /test.txt"
      subnet_type             = "public"
    },
    {
      name                    = "my-instance-2"
      machine_type            = "e2-micro"
      os_family               = "rocky-linux-8"
      os_version              = ""
      tags                    = ["instance-2"]
      attached_disk           = true
      attached_disk_size      = 10
      scratch_disk            = false
      metadata                = { instance = "second" }
      metadata_startup_script = "echo hello > /test2.txt"
      subnet_type             = "private"
      service_account_email   = "service_acc_email"
    }
  ]
