# =============================================================================
# instance.tf - ファイアウォール構成（最終完全版 - CIDRエラー解消済み）
# ・VCN CIDR: 10.0.0.0/16
# ・パブリックSubnet: 10.0.0.0/24
# ・内部Subnet1: 10.1.0.0/24
# ・内部Subnet2: 10.2.0.0/24
# ・ARMインスタンスをFWとして使用（3つのVNIC）
# =============================================================================
# VCN（メインVCN）
resource "oci_core_virtual_network" "vcn_fw_main" {
  compartment_id = var.compartment_id
  cidr_block = "10.0.0.0/16"
  display_name = "vcn-fw-main-20251214"
  dns_label = "vcfwmain"
}
# パブリックSubnet（外部向け）
resource "oci_core_subnet" "subnet_public" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_virtual_network.vcn_fw_main.id
  cidr_block = "10.0.0.0/24"
  display_name = "subnet-public"
  dns_label = "public"
  prohibit_public_ip_on_vnic = false
  route_table_id = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]
}
// Internet Gateway for public subnet
resource "oci_core_internet_gateway" "igw_public" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_virtual_network.vcn_fw_main.id
  display_name = "igw-public"
}

// Route table: 0.0.0.0/0 -> IGW
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_virtual_network.vcn_fw_main.id
  display_name = "public-rt"

  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw_public.id
  }
}

// Security List for public subnet: allow SSH ingress
resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_virtual_network.vcn_fw_main.id
  display_name = "public-sl"

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

// public subnet に作成した RT と Security List を紐付ける
/* subnet_public_patch removed: updated `subnet_public` in-place above */
# 内部Subnet1（10.3.0.0/24）
resource "oci_core_subnet" "subnet_internal_1" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_virtual_network.vcn_fw_main.id
  cidr_block = "10.0.1.0/24"  # 修正: ipv4cidr_blocks → cidr_block
  display_name = "subnet-internal-1"
  dns_label = "internal1"
  prohibit_public_ip_on_vnic = true
}
# 内部Subnet2（10.4.0.0/24）
resource "oci_core_subnet" "subnet_internal_2" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_virtual_network.vcn_fw_main.id
  cidr_block = "10.0.2.0/24"  # 修正: ipv4cidr_blocks → cidr_block
  display_name = "subnet-internal-2"
  dns_label = "internal2"
  prohibit_public_ip_on_vnic = true
}
# ファイアウォール用ARMインスタンス
resource "oci_core_instance" "arm-instance_fw" {
  compartment_id = var.compartment_id
  availability_domain = var.availability_domain
  display_name = "arm-instance_fw"
  # プライマリVNIC - 外部向け
  create_vnic_details {
    subnet_id = oci_core_subnet.subnet_public.id
    assign_public_ip = true
    private_ip = "10.0.0.10"
  }
  shape = "VM.Standard.A1.Flex"
  shape_config {
    ocpus = 4
    memory_in_gbs = 24
  }
  # ARMインスタンス
  source_details {
    source_type = "image"
    source_id = var.image_ocid_oracle10_arm
    boot_volume_size_in_gbs = 100
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
    firmware = "UEFI_64"
    network_type = "PARAVIRTUALIZED"
    remote_data_volume_type = "PARAVIRTUALIZED"
    is_consistent_volume_naming_enabled = true # これを追加
  }
}
# セカンダリVNIC - 10.1.0.0/24 用（FWゲートウェイ）
resource "oci_core_vnic_attachment" "arm-instance_fw_vnic_internal1" {
  instance_id = oci_core_instance.arm-instance_fw.id
  display_name = "fw-internal-1"
  create_vnic_details {
    subnet_id = oci_core_subnet.subnet_internal_1.id
    assign_public_ip = false
    private_ip = "10.0.1.2"
  }
}
# セカンダリVNIC - 10.2.0.0/24 用（FWゲートウェイ）
resource "oci_core_vnic_attachment" "arm-instance_fw_vnic_internal2" {
  instance_id = oci_core_instance.arm-instance_fw.id
  display_name = "fw-internal-2"
  create_vnic_details {
    subnet_id = oci_core_subnet.subnet_internal_2.id
    assign_public_ip = false
    private_ip = "10.0.2.2"
  }
}
# AMDインスタンス - 10.1.0.0/24 ネットワーク
resource "oci_core_instance" "amd_instance_internal1" {
  compartment_id = var.compartment_id
  availability_domain = var.availability_domain
  display_name = "amd-instance-internal1"
  create_vnic_details {
    subnet_id = oci_core_subnet.subnet_internal_1.id
    assign_public_ip = false
    private_ip = "10.0.1.100"
  }
  shape = "VM.Standard.E2.1.Micro"
  source_details {
    source_type = "image"
    source_id = var.image_ocid_oracle10_amd
    boot_volume_size_in_gbs = 50
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"  # 修正: タイポ修正
    firmware = "UEFI_64"
    network_type = "PARAVIRTUALIZED"
    remote_data_volume_type = "PARAVIRTUALIZED"
    is_consistent_volume_naming_enabled = true
  }
}
# AMDインスタンス - 10.2.0.0/24 ネットワーク
resource "oci_core_instance" "amd_instance_internal2" {
  compartment_id = var.compartment_id
  availability_domain = var.availability_domain
  display_name = "amd-instance-internal2"
  create_vnic_details {
    subnet_id = oci_core_subnet.subnet_internal_2.id
    assign_public_ip = false
    private_ip = "10.0.2.100"
  }
  shape = "VM.Standard.E2.1.Micro"
  source_details {
    source_type = "image"
    source_id = var.image_ocid_oracle10_amd
    boot_volume_size_in_gbs = 50
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"  # 修正: タイポ修正
    firmware = "UEFI_64"
    network_type = "PARAVIRTUALIZED"
    remote_data_volume_type = "PARAVIRTUALIZED"
    is_consistent_volume_naming_enabled = true
  }
}
