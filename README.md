# learn-terraform-oci

OCI上に、ARMをFW用途に置いた分離ネットワーク構成をTerraformで作成するリポジトリです。

## 現在の構成

- VCN: `10.0.0.0/16`
- Public Subnet: `10.0.0.0/24`
- Internal Subnet 1: `10.0.1.0/24`
- Internal Subnet 2: `10.0.2.0/24`
- ARM FWインスタンス: `instance-20251213-ARM_fw`
  - Public: `10.0.0.10`（Public IPあり）
  - Internal1側: `10.0.1.2`
  - Internal2側: `10.0.2.2`
- AMDインスタンス1: `amd-instance-internal1` (`10.0.1.100`)
- AMDインスタンス2: `amd-instance-internal2` (`10.0.2.100`)

## ファイル構成

- `main.tf`: OCI provider設定
- `variables.tf`: 入力変数定義
- `instance.tf`: ネットワークとインスタンス定義

## 重要な注意

- このリポジトリは **VCN/Subnet/IGW/Route Table/Security List もTerraformで管理** します。
- `source_id`（イメージOCID）、CIDR、固定Private IP、shapeはコードにハードコードされています。
- 機密値（`tenancy_ocid` など）は `terraform.tfvars` に設定してください。

## 事前準備

- Terraform 1.x
- OCIアカウント
- OCI APIキー
- SSH公開鍵

## 変数設定（terraform.tfvars）

`terraform.tfvars` を作成し、以下を設定します。

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
git clone <this-repo>
cd learn-terraform-oci

terraform init
terraform plan
terraform apply
```

削除:

```bash
terraform destroy
```

## SSH接続

1. まずARM FWへ接続

```bash
ssh -i <private-key.pem> opc@<ARM_FW_PUBLIC_IP>
```

2. ARM FWから内部AMDへ接続

```bash
ssh opc@10.0.1.100
ssh opc@10.0.2.100
```

3. ローカルからProxyJumpで直接接続

```bash
ssh -i <private-key.pem> -J opc@<ARM_FW_PUBLIC_IP> opc@10.0.1.100
ssh -i <private-key.pem> -J opc@<ARM_FW_PUBLIC_IP> opc@10.0.2.100
```

## 変更時の目安

- インスタンス追加/削除: `instance.tf` を編集して `terraform plan/apply`
- 変数追加: `variables.tf` と `terraform.tfvars` を更新
- provider設定変更: `main.tf` を更新
