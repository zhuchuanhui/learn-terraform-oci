

resource "oci_core_vcn" "internal" {
  dns_label      = "internal"
  cidr_block     = "172.16.0.0/20"
  # tenancy_ocid   = var.tenancy_ocid
  compartment_id   = var.compartment_id
  display_name   = "My internal VCN"
}

resource "oci_core_subnet" "dev" {
  vcn_id                      = oci_core_vcn.internal.id
  cidr_block                  = "172.16.0.0/24"
  # tenancy_ocid                = var.tenancy_ocid
  compartment_id              = var.compartment_id
  display_name                = "Dev subnet 1"
  prohibit_public_ip_on_vnic  = true
  dns_label                   = "dev"
}

#インポート済みリソース
resource "oci_core_virtual_network" "vcn_ubuntu22_test1" {
  cidr_block                  = "10.0.0.0/16"
  compartment_id              = var.compartment_id
  display_name                = "vcn-20240229-ubuntu22-test1"
  dns_label                   = "vcn02292221"
  defined_tags                = {
    "Oracle-Tags.CreatedBy"  = "default/syudenky@gmail.com"
    "Oracle-Tags.CreatedOn"  = "2024-02-29T13:21:45.300Z"
  }
  freeform_tags              = {}
}
