resource "oci_core_vcn" "prod_vcn_1" {
  compartment_id = oci_identity_compartment.network_compartment.id
  cidr_blocks    = var.prod_vcn_cidr
  display_name   = var.prod_vcn_name

  # Add these lines to enable DNS
  dns_label      = var.prod_vcn_dns_label
  is_ipv6enabled = false
}

# --- Gateways ---
resource "oci_core_internet_gateway" "igw_prod_vcn_1" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.prod_vcn_1.id
  display_name   = "${var.prod_vcn_name}-internet-gateway"
  enabled        = true
}

resource "oci_core_nat_gateway" "gw_nat_prod_vcn_1" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.prod_vcn_1.id
  display_name   = "${var.prod_vcn_name}-nat"
}


# --- Route tables ---
resource "oci_core_route_table" "rt_prod_vcn_1" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.prod_vcn_1.id
  display_name   = "${var.prod_vcn_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw_prod_vcn_1.id
  }
}

# --- Security lists (simple baseline) ---
resource "oci_core_security_list" "sl_prod_vcn_1" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.prod_vcn_1.id
  display_name   = "${var.prod_vcn_name}-public-sl"

  # Allow SSH from your chosen CIDR (default is 0.0.0.0/0; change it!)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.my_public_ip
    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
}


# --- Subnets ---
resource "oci_core_subnet" "public_subnet" {
  compartment_id      = oci_identity_compartment.network_compartment.id
  vcn_id              = oci_core_vcn.prod_vcn_1.id
  cidr_block         = var.prod_public_subnet_cidr
  display_name        = var.prod_public_subnet_name
  dns_label           = var.prod_public_subnet_dns_label
  prohibit_public_ip_on_vnic = false  # <-- public IPs allowed

  route_table_id      = oci_core_route_table.rt_prod_vcn_1.id
  security_list_ids   = [oci_core_security_list.sl_prod_vcn_1.id]
}