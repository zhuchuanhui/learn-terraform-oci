# =============================================================================
# instance.tf
# 目的: 管理対象のOCIリソース（VCN、Subnet、2台の既存インスタンス）を定義
# 内容: インポート済みの既存リソースをTerraformで管理するための設定
# 注意: source_id はOCIコンソールから取得したイメージOCIDに置き換えてください
# =============================================================================

# 既存のVCN（インポート済み）
resource "oci_core_virtual_network" "vcn_test1" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  display_name   = "vcn-20251213-test1"
  dns_label      = "vcn02292221"

  defined_tags = {
    "Oracle-Tags.CreatedBy" = "default/syudenky@gmail.com"
    "Oracle-Tags.CreatedOn" = "2024-02-29T13:21:45.300Z"
  }
}

# 既存のSubnet（コンソールと完全に一致させる）
resource "oci_core_subnet" "dev" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_virtual_network.vcn_test1.id
  cidr_block                 = "10.0.0.0/24"
  display_name               = "subnet-20240229-ubuntu22-test1"  # コンソール一致
  dns_label                  = "subnet02292221"                  # コンソール一致
  prohibit_public_ip_on_vnic = false
}

# 1台目: ARMインスタンス（Ampere A1 Flex）
resource "oci_core_instance" "existing_instance" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain

  display_name = "instance-20251213-ARM"

  create_vnic_details {
    subnet_id        = oci_core_subnet.dev.id
    assign_public_ip = true
  }

  shape = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  # ARMインスタンス
  source_details {
    source_type             = "image"
    source_id               = "ocid1.image.oc1.ap-osaka-1.aaaaaaaatstm2fpjmgo3zqsgyfpmujr5vlrse7kkhfbkp4kfiyinmzuh72xa"
    boot_volume_size_in_gbs = 100
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    network_type                        = "PARAVIRTUALIZED"
    remote_data_volume_type             = "PARAVIRTUALIZED"
    is_pv_encryption_in_transit_enabled = true
    is_consistent_volume_naming_enabled = true  # これを追加
  }
}

# 2台目: AMDインスタンス（Always Free Micro）
resource "oci_core_instance" "existing_instance1" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain

  display_name = "instance-20251213-AMD1"

  create_vnic_details {
    subnet_id        = oci_core_subnet.dev.id
    assign_public_ip = true
  }

  shape = "VM.Standard.E2.1.Micro"

  # AMDインスタンス
  source_details {
    source_type             = "image"
    source_id               = "ocid1.image.oc1.ap-osaka-1.aaaaaaaan3hdtcxksx6at4azuusiyldtv6gcn2ev32pfqm72unn75eyb66sa"
    boot_volume_size_in_gbs = 50
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    network_type                        = "PARAVIRTUALIZED"
    remote_data_volume_type             = "PARAVIRTUALIZED"
    is_pv_encryption_in_transit_enabled = true
    is_consistent_volume_naming_enabled = true  # これを追加
  }
}

# 新規AMDインスタンス（existing_instance1と同じスペック）
resource "oci_core_instance" "new_amd_instance" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain

  display_name = "instance-20251213-AMD2"  # 任意の名前

  create_vnic_details {
    subnet_id        = oci_core_subnet.dev.id
    assign_public_ip = true
  }

  shape = "VM.Standard.E2.1.Micro"

  source_details {
    source_type             = "image"
    source_id               = "ocid1.image.oc1.ap-osaka-1.aaaaaaaan3hdtcxksx6at4azuusiyldtv6gcn2ev32pfqm72unn75eyb66sa"  # 現在のAMDと同じimage OCID
    boot_volume_size_in_gbs = 50
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    network_type                        = "PARAVIRTUALIZED"
    remote_data_volume_type             = "PARAVIRTUALIZED"
    is_pv_encryption_in_transit_enabled = true
    is_consistent_volume_naming_enabled = true
  }
}
