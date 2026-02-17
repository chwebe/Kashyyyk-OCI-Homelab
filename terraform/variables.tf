############################################
# Compartments
############################################

variable "root_compartment_id" {
  description = "The OCID of the parent compartment where the resources will be created."
  type        = string
}

variable "prod_compartment_name" {
  description = "OCID of your compartment"
  type        = string
}

variable "prod_compartment_description" {
  description = "The first compartment"
  type        = string
}

variable "network_compartment_name" {
  description = "The network compartment name"
  type        = string
}

variable "network_compartment_description" {
  description = "The network compartment description"
  type        = string
}

variable "instance_compartment_name" {
  description = "VMs compartment"
  type        = string
  default     = "INSTANCES"
}


############################################
# VCN
############################################

variable "prod_vcn_name" {
  type = string
  default = "prod_vcn_1"
}

variable "prod_vcn_dns_label" { 
  type    = string 
  default = "prodvcn" 
}

variable "prod_vcn_cidr"         { 
  type = list(string) 
  default = ["10.0.0.0/24"] 
}

variable "prod_public_subnet_cidr" { 
  type = string 
  default = "10.0.0.0/27" 
}

variable "prod_public_subnet_dns_label" { 
  type = string 
  default = "pubsn" 
}

variable "prod_public_subnet_name" { 
  type = string 
  default = "prod-public-subnet"
}


# IMPORTANT: best practice is to set this to YOUR public IP /32.
variable "my_public_ip" {
  type    = string
  default = "82.64.239.99/32"
}

############################################
# VM Instance (Always Free Tier)
############################################

variable "vm_display_name" {
  type    = string
  default = "wireguard-vm"
}

variable "vm_shape" {
  type    = string
  default = "VM.Standard.E2.1.Micro"  # Always Free ARM shape
}

variable "vm_ocpus" {
  type    = number
  default = 1  # Free tier: 1-4 OCPUs
}

variable "vm_memory_in_gbs" {
  type    = number
  default = 1  # Free tier: 1-24 GB
}

variable "vm_image_id" {
  type    = string
  default = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaayy7g3zqj6zvd3cl4x6xyq7t3wj4c5df3x4c3z3q4q4q4q4q4q4q"
}

variable "vm_ssh_public_key" {
  type    = string
  description = "SSH public key for VM access"
}