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
  auth                = "SecurityToken"
  config_file_profile = "learn-terraform"
}
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

resource "oci_core_instance" "existing_instance" {
  compartment_id   = var.compartment_id
  # インポート後に情報がここに挿入されます
}

resource "oci_core_instance" "existing_instance1" {
  compartment_id   = var.compartment_id
  # インポート後に情報がここに挿入されます
}

resource "oci_core_instance" "existing_instance2" {
  compartment_id   = var.compartment_id
  # インポート後に情報がここに挿入されます
}
