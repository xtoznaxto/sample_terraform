variable "port_network_id" {}
variable "port_subnet_id" {}
variable "port_fixed_ip" {}
variable "port_additional_network_id" { default = null }
variable "port_additional_subnet_id" { default = null }
variable "port_additional_fixed_ip" { default = null }
variable "new_vm_name" {}
variable "new_vm_flavor_name" {}
variable "new_vm_etalon_image_id" {}
variable "new_vm_root_volume_size_gb" { default = 10 }
variable "ipa_provisioner_password" { 
    sensitive = true
    }
variable "additional_volume" { 
    type = bool
    default = false 
    }
variable "additional_volume_size_gb" { default = null }
  