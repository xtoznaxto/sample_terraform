variable "ipa_pass" { 
  sensitive = true
}

variable "etalon-centos7-kernel4-v1" {
  default     = ""
}
variable "etalon-centos7-kernel4-v2" {
  default     = ""
}
variable "etalon-centos7-kernel4-v3" {
  default     = ""
}
variable "NET_ID" {
  description = "[network_id, subnet_id]"
}

locals {
  vm_vars = {
    # hostname = [ip, flavor, root_vol_size_gb, add_vol_bool, add_vol_size_gb, net]
    "api1" = ["10.1.1.15", "8RAM-8CPU-10DISK", "10", "false", "0", var.NET_ID.NET_10_1_1]
    "api2" = ["10.1.1.16", "8RAM-8CPU-10DISK", "10", "false", "0", var.NET_ID.NET_10_1_1]
    "db1" = ["10.1.2.13", "8RAM-6CPU-10DISK", "10", "true", "100", var.NET_ID.NET_10_1_2]
    "db2" = ["10.1.2.14", "8RAM-6CPU-10DISK", "10", "true", "100", var.NET_ID.NET_10_1_2]
  }
}

module "vm" {
  source   = "../modules/new_vm_2disks"
  for_each = local.vm_vars
  port_fixed_ip = each.value[0]
  new_vm_name = each.key
  new_vm_flavor_name = each.value[1]
  new_vm_etalon_image_id = var.etalon-centos7-kernel4-v2
  new_vm_root_volume_size_gb = each.value[2]
  additional_volume = each.value[3]
  additional_volume_size_gb = each.value[4]
  port_network_id = each.value[5][0]
  port_subnet_id = each.value[5][1]
  ipa_provisioner_password = var.ipa_pass
}