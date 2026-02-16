resource "oci_identity_compartment" "prod_compartment" {
  compartment_id = var.root_compartment_id
  description    = var.prod_compartment_description
  name           = "${var.prod_compartment_name}"
}

resource "oci_identity_compartment" "network_compartment" {
  compartment_id = oci_identity_compartment.prod_compartment.id
  description    = var.network_compartment_description
  name           = "${var.network_compartment_name}"
}

