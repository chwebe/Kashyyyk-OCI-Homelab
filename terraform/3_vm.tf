# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = oci_identity_compartment.network_compartment.id
}

# Get latest Ubuntu 22.04 LTS platform image
data "oci_core_images" "ubuntu_images" {
  compartment_id           = var.root_compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = var.vm_shape
  state                    = "AVAILABLE"
}

# Fallback: Get any Ubuntu 22.04 image if platform images not found
data "oci_core_images" "ubuntu_fallback" {
  compartment_id           = var.root_compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  state                    = "AVAILABLE"
}

resource "oci_core_instance" "wireguard_vm" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.instance_compartment.id
  display_name        = var.vm_display_name
  shape               = var.vm_shape
  shape_config {
    ocpus         = var.vm_ocpus
    memory_in_gbs = var.vm_memory_in_gbs
  }

  source_details {
    source_type = "image"
    source_id   = length(data.oci_core_images.ubuntu_images.images) > 0 ? data.oci_core_images.ubuntu_images.images[0].id : var.vm_image_id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    display_name     = "primary-vnic"
    assign_public_ip = true
    hostname_label   = "wireguard"
  }

  metadata = {
    ssh_authorized_keys = var.vm_ssh_public_key
  }

  preserve_boot_volume = false
  freeform_tags = {
    "Environment" = "production"
    "Purpose"     = "wireguard-vpn"
  }
}
