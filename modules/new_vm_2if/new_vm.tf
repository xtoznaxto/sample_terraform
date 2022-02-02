resource "openstack_networking_port_v2" "new_vm_port" {
  network_id     = var.port_network_id
  admin_state_up = "true"
  port_security_enabled = "false"
  fixed_ip {
    subnet_id = var.port_subnet_id
    ip_address = var.port_fixed_ip
  }
}
resource "openstack_networking_port_v2" "new_vm_port_additional" {
  count = var.port_additional ? 1 : 0
  network_id     = var.port_additional_network_id
  admin_state_up = "true"
  port_security_enabled = "false"
  fixed_ip {
    subnet_id = var.port_additional_subnet_id
    ip_address = var.port_additional_fixed_ip
  }
}
#resource "openstack_compute_interface_attach_v2" "new_vm_port_additional_attach" {
#  count = var.port_additional ? 1 : 0
#  instance_id = "${openstack_compute_instance_v2.new_vm.id}"
##  network_id     = var.port_additional_network_id
#  port_id  = "${openstack_networking_port_v2.new_vm_port_additional.0.id}"
#  fixed_ip = var.port_additional_fixed_ip
#}

resource "openstack_compute_instance_v2" "new_vm" {
  name            = var.new_vm_name
  flavor_name     = var.new_vm_flavor_name
  network {
    port = openstack_networking_port_v2.new_vm_port.id
  }
  network {
    port = openstack_networking_port_v2.new_vm_port_additional.0.id
  }
  block_device {
    uuid = var.new_vm_etalon_image_id
    source_type = "image"
    boot_index = 0
    volume_size = var.new_vm_root_volume_size_gb
    destination_type = "volume"
    delete_on_termination = true
  }
  user_data = <<-EOF
  #cloud-config
  runcmd:
    - ipa-client-install --enable-dns-updates --mkhome -pipa_provisioner_name -w"${var.ipa_provisioner_password}" --unattended && for i in $(grep -Rl 'ipa_provisioner_name' /var/lib/cloud/); do sed -i '/ipa_provisioner_name/c\ipa-client-install --enable-dns-updates --mkhome -pipa_provisioner_name -wSECRET' $i; done
    - pvcreate /dev/vdb1 && vgcreate vg_home /dev/vdb1 && lvcreate -l 100%FREE -n lv_home vg_home /dev/vdb1 && mkfs.xfs /dev/vg_home/lv_home && echo '/dev/vg_home/lv_home /home xfs defaults,nofail 0 0' >> /etc/fstab
  users:
    - name: prod
      sudo: False
  EOF
}
resource "openstack_blockstorage_volume_v3" "volumes" {
  count = var.additional_volume ? 1 : 0
  size  = var.additional_volume_size_gb
  enable_online_resize = true
}
resource "openstack_compute_volume_attach_v2" "attach_1" {
  count = var.additional_volume ? 1 : 0
  instance_id = "${openstack_compute_instance_v2.new_vm.id}"
  volume_id   = openstack_blockstorage_volume_v3.volumes.0.id
}