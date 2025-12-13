# learn-terraform-oci プロジェクト README

このプロジェクトは、Oracle Cloud Infrastructure (OCI) の無料枠（Always Free）で作成した  
- 1つのVCN  
- 1つのパブリックSubnet  
- ARMインスタンス 1台 (VM.Standard.A1.Flex, 4 OCPU / 24GB)  
- AMDインスタンス 2台 (VM.Standard.E2.1.Micro)  

をTerraformで管理するための構成です。

長期間のトラブルシューティングの結果、**VCNとSubnetはOCIコンソールで作成したものをそのまま使い、Terraformではインスタンスのみを管理**する形に落ち着きました。これが最も安定します。

## 現在の構成概要

- **VCN**: vcn-20240229-ubuntu22-test1 (CIDR: 10.0.0.0/16)
- **Subnet**: subnet-20240229-ubuntu22-test1 (CIDR: 10.0.0.0/24, パブリック)
- **インスタンス**:
  - `existing_instance` : ARM (A1.Flex)
  - `existing_instance1` : AMD Micro (元々の1台目)
  - `new_amd_instance` : AMD Micro (新規追加)

## ファイル構成

```
learn-terraform-oci/
├── main.tf              # プロバイダー設定のみ
├── variables.tf         # 変数宣言
├── terraform.tfvars     # 実際の値（機密情報）
├── instance.tf          # インスタンス定義（VCN/Subnetは管理外）
└── README.md            # このファイル
```

## 使い方（誰でも修正・追加できるように）

### 1. 事前準備
- OCIアカウントでAPIキーを作成済み
- `~/.ssh/id_rsa.pub` にSSH公開キーがある
- OCIコンソールで以下のリソースが作成済み（このプロジェクトではTerraformで管理しません）
  - VCN: vcn-20240229-ubuntu22-test1
  - Subnet: subnet-20240229-ubuntu22-test1 (パブリック)

### 2. セットアップ
```bash
git clone <このリポジトリ>
cd learn-terraform-oci

# 変数値を設定（terraform.tfvarsを編集）
cp terraform.tfvars.example terraform.tfvars
# エディタで開いて値を埋める

terraform init
```

### 3. インスタンス作成・変更
```bash
terraform plan    # 変更内容を確認
terraform apply   # yes と入力
```

### 4. 新しいインスタンスを追加したい場合
`instance.tf` に新しいリソースブロックをコピーして追加してください。

例：もう1台AMD Microを追加したい場合
```hcl
resource "oci_core_instance" "another_amd_instance" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain

  display_name = "another-amd-instance"

  create_vnic_details {
    subnet_id        = "ocid1.subnet.oc1.ap-osaka-1.aaaaaaaa4sbehj6px5z3eevg452jt3mjzrgkcxjqvnjt6vjpfotvnj3ftebq"  # 固定（コンソールのSubnet OCID）
    assign_public_ip = true
  }

  shape = "VM.Standard.E2.1.Micro"

  source_details {
    source_type             = "image"
    source_id               = "ocid1.image.oc1.ap-osaka-1.aaaaaaaan3hdtcxksx6at4azuusiyldtv6gcn2ev32pfqm72unn75eyb66sa"  # AMD用image OCID
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
```

変更後：
```bash
terraform plan
terraform apply
```

### 5. インスタンスを削除したい場合
`instance.tf` から該当ブロックを削除 or コメントアウトしてapply。

### 6. 注意点
- **VCNとSubnetは絶対にTerraformで管理しない**（過去にトラブル多発）
- Subnet OCIDとimage OCIDは固定でハードコードしています
- 機密情報（tenancy_ocid, user_ocid, fingerprint, private_key_path, ssh_public_key）は`terraform.tfvars`に記載
- `.gitignore`に`terraform.tfvars`と`.terraform*`を追加推奨

### 7. トラブルシューティング
- `terraform plan` でreplaceが多く出る → `terraform state rm <resource>` で古いstateを削除して再import
- エラーでapply中断 → stateバックアップを取ってからstate rmでクリーンアップ

これで誰でも安全にインスタンスを追加・削除・管理できます！  
お疲れ様でした。この構成で安定運用してください。
