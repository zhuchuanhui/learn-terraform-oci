# learn-terraform-oci_2

OCI上に、以下のネットワーク分離構成をTerraformで作成するリポジトリです。

- VCN: `10.0.0.0/16`
- Public Subnet: `10.0.0.0/24`
- Internal Subnet 1: `10.0.1.0/24`
- Internal Subnet 2: `10.0.2.0/24`
- ARMインスタンス 1台（FW用途・3 VNIC）
- AMDインスタンス 2台（内部サブネットに配置）

## 構成

- `main.tf`
  - OCI provider定義
- `variables.tf`
  - 入力変数定義
- `instance.tf`
  - ネットワーク（VCN/Subnet/IGW/Route/Security List）とインスタンス定義
- `terraform.tfvars`
  - 環境ごとの値（認証情報、コンパートメント、SSH鍵など）

## 作成される主なリソース

- `oci_core_virtual_network.vcn_fw_main`
- `oci_core_subnet.subnet_public`
- `oci_core_subnet.subnet_internal_1`
- `oci_core_subnet.subnet_internal_2`
- `oci_core_internet_gateway.igw_public`
- `oci_core_route_table.public_rt`
- `oci_core_security_list.public_sl`
- `oci_core_instance.instance-20251213-ARM_fw`
- `oci_core_vnic_attachment.instance-20251213-ARM_fw_vnic_internal1`
- `oci_core_vnic_attachment.instance-20251213-ARM_fw_vnic_internal2`
- `oci_core_instance.amd_instance_internal1`
- `oci_core_instance.amd_instance_internal2`

## ネットワーク概要

```text
Internet
  |
  v
[Public Subnet 10.0.0.0/24]
  |- ARM FW (10.0.0.10, Public IPあり)
      |- VNIC: 10.0.1.2 (Internal1側)
      |- VNIC: 10.0.2.2 (Internal2側)

[Internal Subnet1 10.0.1.0/24]
  |- AMD: 10.0.1.100 (Public IPなし)

[Internal Subnet2 10.0.2.0/24]
  |- AMD: 10.0.2.100 (Public IPなし)
```

## 前提

- Terraform 1.x
- OCIアカウント/権限
- OCI API Key作成済み
- 接続に使うSSH公開鍵

## セットアップ

```bash
git clone <this-repo>
cd learn-terraform-oci_2
```

`terraform.tfvars` を用意し、少なくとも以下を設定してください。

```hcl
tenancy_ocid        = "ocid1.tenancy..."
compartment_id      = "ocid1.compartment..."
user_ocid           = "ocid1.user..."
fingerprint         = "xx:xx:xx:..."
private_key_path    = "~/.oci/oci_api_key.pem"
region              = "ap-osaka-1"
availability_domain = "ZXGQ:AP-OSAKA-1-AD-1"
ssh_public_key      = "ssh-rsa AAAA..."
```

## 実行手順

```bash
terraform init
terraform plan
terraform apply
```

削除する場合:

```bash
terraform destroy
```

## SSH接続

1. ARM FWへ接続

```bash
ssh -i <private-key.pem> opc@<ARM_FW_PUBLIC_IP>
```

2. ARM FW経由で内部AMDへ接続

```bash
# Internal1
ssh -i <private-key.pem> -J opc@<ARM_FW_PUBLIC_IP> opc@10.0.1.100

# Internal2
ssh -i <private-key.pem> -J opc@<ARM_FW_PUBLIC_IP> opc@10.0.2.100
```

## 実装上の注意

- このリポジトリは **VCN/Subnet/IGW/Route Table/Security List もTerraformで管理** します。
- `instance.tf` には以下がハードコードされています。
  - CIDR
  - 各インスタンスの固定Private IP
  - `source_id`（イメージOCID）
  - インスタンスshape/volumeサイズ
- 環境差分がある場合は `instance.tf` を編集してください。

## 変更時の目安

- インスタンス追加/削除: `instance.tf` を編集して `terraform plan/apply`
- 変数追加: `variables.tf` と `terraform.tfvars` を更新
- provider設定変更: `main.tf` を更新
