variable "project" {
  description = "The GCP project ID where the resources will be created."
  type        = string
  default     = "test-ntr-465513"
}

variable "region" {
  description = "The GCP region where the resources will be created."
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "The GCP zone where the resources will be created."
  type        = string
  default     = "europe-west1-b"
}

variable "vpc_name" {
  description = "VPC network name."
  type        = string
  default     = "vpc1"
}

variable "public_subnet_name" {
  description = "Public subnet name."
  type        = string
  default     = "public-subnet"
}

variable "private_subnet_name" {
  description = "Public subnet name."
  type        = string
  default     = "private-subnet"
}

variable "create_ssh_key" {
  description = "Whether to create an SSH key for the instances."
  type        = bool
  default     = false
}

variable "ssh_username" {
  description = "Username to use for the SSH key."
  type        = string
  default     = "user"
}

variable "instances" {
  description = "Number of VM instances to create."
  type = list(object({
    name                    = string
    machine_type            = string
    os_family               = string
    os_version              = string
    tags                    = list(string)
    subnet_type             = string
    attached_disk           = optional(bool)
    attached_disk_size      = optional(number)
    scratch_disk            = optional(bool)
    scratch_disk_interface  = optional(string)
    boot_disk_type          = optional(string)
    boot_disk_size_gb       = optional(number)
    metadata                = map(string)
    metadata_startup_script = optional(string)
    service_account_email   = optional(string)

  }))
  default = [{
    name                    = "my-instance-1"
    machine_type            = "e2-micro"
    os_family               = "rocky-linux-8"
    os_version              = ""
    tags                    = ["instance", "public"]
    attached_disk           = false
    scratch_disk            = false
    metadata                = { instance = "1" }
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
      metadata                = { instance = "2" }
      metadata_startup_script = "echo hello > /test2.txt"
      subnet_type             = "private"
  }]
}
