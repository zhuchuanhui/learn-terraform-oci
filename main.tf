terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  tenancy_ocid        = var.tenancy_ocid      // テナントOCID
  # compartment_id      = var.compartment_id    // テナントOCID
  user_ocid           = var.user_ocid         // ユーザーOCID
  fingerprint         = var.fingerprint       // APIキーのフィンガープリント
  private_key_path    = var.private_key_path       // プライベートキーのファイルパス
  region              = var.region            // 使用するリージョン
  # auth                = "SecurityToken"
  # config_file_profile = "learn-terraform"
}

# resource "oci_core_vcn" "internal" {
#   dns_label      = "internal"
#   cidr_block     = "172.16.0.0/20"
#   # tenancy_ocid   = var.tenancy_ocid
#   compartment_id   = var.compartment_id
#   display_name   = "My internal VCN"
# }

# resource "oci_core_subnet" "dev" {
#   vcn_id                      = oci_core_vcn.internal.id
#   cidr_block                  = "172.16.0.0/24"
#   # tenancy_ocid                = var.tenancy_ocid
#   compartment_id              = var.compartment_id
#   display_name                = "Dev subnet 1"
#   prohibit_public_ip_on_vnic  = true
#   dns_label                   = "dev"
# }


#インポートリソース
# resource "oci_core_virtual_network" "vcn_ubuntu22_test1" {
#   # インポート後にリソースの詳細を更新するので、ここでは空の状態にします。
# }
# resource "oci_core_virtual_network" "vcn_ubuntu22_test1" {
#   cidr_block                  = "10.0.0.0/16"
#   compartment_id              = var.compartment_id
#   display_name                = "vcn-20240229-ubuntu22-test1"
#   dns_label                   = "vcn02292221"
#   defined_tags                = {
#     "Oracle-Tags.CreatedBy"  = "default/syudenky@gmail.com"
#     "Oracle-Tags.CreatedOn"  = "2024-02-29T13:21:45.300Z"
#   }
#   freeform_tags              = {}
# }

# resource "oci_core_instance" "existing_instance" { #ARM device
#   compartment_id   = var.compartment_id
#   availability_domain = var.availability_domain
#   # インポート後に情報がここに挿入してください
# }

# resource "oci_core_instance" "existing_instance1" { #AMD device1
#   compartment_id   = var.compartment_id
#   availability_domain = var.availability_domain
#   # インポート後に情報がここに挿入してください
# }

# resource "oci_core_instance" "existing_instance2" { #AMD device2
#   compartment_id   = var.compartment_id
#   availability_domain = var.availability_domain
#   # インポート後に情報がここに挿入してください
# }
