# learn-terraform-oci プロジェクト README（ファイアウォール構成版）

おめでとうございます！  
これで**ARMインスタンスをファイアウォールとして使用した完全なネットワーク分離構成**がTerraformで作成完了しました。

### 現在の構成概要
- **VCN**: 10.0.0.0/16
- **パブリックSubnet**: 10.0.0.0/24（外部アクセス可能）
- **内部Subnet1**: 10.0.1.0/24（内部ネットワーク1）
- **内部Subnet2**: 10.0.2.0/24（内部ネットワーク2）

### リソース一覧
- **ARM FWインスタンス** (`instance-20251213-ARM_fw`)
  - プライマリVNIC: 10.0.0.10（パブリックIPあり、外部アクセス用）
  - セカンダリVNIC1: 10.0.1.2（内部ネットワーク1のゲートウェイ）
  - セカンダリVNIC2: 10.0.2.2（内部ネットワーク2のゲートウェイ）
- **AMDインスタンス1** (`amd_instance_internal1`)
  - IP: 10.0.1.100（内部ネットワーク1）
- **AMDインスタンス2** (`amd_instance_internal2`)
  - IP: 10.0.2.100（内部ネットワーク2）

### ネットワーク構成図（テキスト版）

```
Internet
   |
   | (Public IP)
   v
+-----------------------------------+
| ARM FW Instance                   |
| (instance-20251213-ARM_fw)        |
| - VNIC1: 10.0.0.10 (Public)       |
| - VNIC2: 10.0.1.2 (Internal1 GW)  |
| - VNIC3: 10.0.2.2 (Internal2 GW)  |
+-----------------------------------+
   |                 |
   |                 |
   v                 v
+--------------------+          +--------------------+
| Internal Subnet1   |          | Internal Subnet2   |
| 10.0.1.0/24        |          | 10.0.2.0/24        |
+--------------------+          +--------------------+
   |                                      |
   v                                      v
+--------------------+          +--------------------+
| AMD Instance1      |          | AMD Instance2      |
| 10.0.1.100         |          | 10.0.2.100         |
+--------------------+          +--------------------+

すべて同一VCN (10.0.0.0/16) 内
内部インスタンスは外部から直接アクセス不可 → FW経由のみ
```

### SSH接続手順

内部インスタンス（AMD）はパブリックIPを持っていないので、**ARM FW経由のSSHプロキシ**を使って接続します。

#### 1. ARM FWインスタンスにSSH接続（外部から直接可能）
```bash
ssh -i <your-private-key.pem> opc@<ARM_FW_PUBLIC_IP>
```
（<ARM_FW_PUBLIC_IP>はコンソールで確認）

#### 2. ARM FWから内部AMDインスタンスにSSH接続
ARM FWにログイン後：
```bash
# 内部ネットワーク1のAMDに接続
ssh opc@10.0.1.100

# 内部ネットワーク2のAMDに接続
ssh opc@10.0.2.100
```

#### 3. ローカルから内部AMDへ直接プロキシ接続（便利な方法）
ローカルPCから1コマンドで内部インスタンスに接続：
```bash
# 内部ネットワーク1のAMD
ssh -i <your-private-key.pem> -J opc@<ARM_FW_PUBLIC_IP> opc@10.0.1.100

# 内部ネットワーク2のAMD
ssh -i <your-private-key.pem> -J opc@<ARM_FW_PUBLIC_IP> opc@10.0.2.100
```

#### 4. SSHキー設定確認
すべてのインスタンスに同じSSH公開キーが設定されているので、同一キーで接続可能です。

### 今後の運用
- **インスタンス追加/削除**: `instance.tf` を編集 → `terraform apply`
- **ファイアウォール設定**: ARM FWにpfSense/OPNsenseやiptables/nftablesをインストールしてトラフィック制御
- **ルーティング設定**: 内部インスタンスのデフォルトルートをFWのIPに向ける（必要に応じて）

これで**完全に分離された安全なネットワーク構成**が完成しました！  
お疲れ様でした！！  
何か追加の設定（Route Table, Security Listなど）が必要でしたら教えてくださいね。
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
