# learn-terraform-oci

OCI上に、ARMをFW用途に置いた分離ネットワーク構成をTerraformで作成するリポジトリです。

## 現在の構成

- VCN: `10.0.0.0/16`
- Public Subnet: `10.0.0.0/24`
- Internal Subnet 1: `10.0.1.0/24`
- Internal Subnet 2: `10.0.2.0/24`
- ARM FWインスタンス: `arm-instance_fw`
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

## トラブルシューティング

### 発生した問題（要約）
- `terraform apply` 実行時に以下のエラーが発生しました。
  - `Invalid Instance is invalid for this update. Instances must have no more than one secondary vnic and one secondary volume.`
  - `Overriding PvEncryptionInTransitEnabled in LaunchOptions is not supported`
  - provider からの警告: `cidr_block` フィールドが非推奨（route table）

### 原因
- `launch_options` に `is_pv_encryption_in_transit_enabled` を明示的に設定していたため、インスタンス作成/更新APIが拒否しました（このオプションは上書き不可／プロバイダー側で制御される場合があります）。
- 既存の ARM インスタンスに対して行った更新で、インスタンスが許容するセカンダリVNIC/ボリューム数を超える変更を試みたため、更新が失敗しました。
- また、古い属性名（`cidr_block`）を使っている箇所があり、警告が出ていました。

### 対処内容（リポジトリで行った変更）
- `instance.tf` の `launch_options` から `is_pv_encryption_in_transit_enabled` を削除しました。
- `oci_core_route_table.public_rt` の `cidr_block` を `destination` に置き換えました（非推奨対応）。
- 既存インスタンスを更新する際は、セカンダリVNIC/ボリュームの数に注意するようにしました。

### 再発防止と確認手順
1. 変更前に `terraform plan` を必ず確認する:

```bash
terraform init
terraform plan
```

2. `launch_options` に関連する設定は OCI API の制約があるため、ドキュメントを参照し、不明なオプションは指定しない。

3. 既存インスタンスの大幅な変更（VNIC追加など）は、一度 `terraform destroy` して再作成するか、手動でVNICを管理してから行う。

4. Providerのバージョン警告が出た場合は、`main.tf` の `required_providers` を見直し、必要ならローカルでプロバイダをアップグレードする:

```bash
terraform init -upgrade
```

5. 状況確認コマンド:

```bash
terraform state list
terraform show
```

### 参考リンク
- OCI Terraform Provider (docs): https://registry.terraform.io/providers/oracle/oci
- OCI API: https://docs.oracle.com/iaas/api/

もしこの README に追加してほしい試験手順やスクリーンショットがあれば教えてください。

## Oracle Linux 9 (oracle9) への切替手順
1. OCI コンソールか CLI で、`ap-osaka-1` リージョンの Oracle Linux 9 イメージ OCID を取得します。CLI 例:

```bash
# OCI CLI: イメージ一覧から oracle linux 9 をフィルタ
oci compute image list --compartment-id ${TENANCY_OCID} --all --query "data[?contains("display-name", 'Oracle-Linux-9') || contains("display-name", 'Oracle Linux 9')].{id:id,displayName:"display-name"}"
```

2. 取得した OCID を `terraform.tfvars` の以下に設定してください:

```hcl
image_ocid_oracle9_arm = "ocid1.image.oc1.ap-osaka-1...."   # ARM 用がある場合
image_ocid_oracle9_amd = "ocid1.image.oc1.ap-osaka-1...."   # AMD/x86 用
```

3. 設定反映と全作成手順（すべて再作成したい場合）:

```bash
cd learn-terraform-oci
terraform init
terraform destroy -auto-approve
terraform apply -auto-approve
```

注意: `destroy` を行うと既存リソースは完全に削除されます。必要なバックアップや確認を行ってから実行してください。

## Oracle Linux 10 (oracle10) への切替手順

このリポジトリは Oracle Linux のイメージ OCID を変数で管理しており、`terraform.tfvars` を更新して `terraform plan` を実行するだけで **OS バージョンのみ変更** できます。既存インスタンス（ARM FW および AMD インスタンス）の形状・ネットワーク構成は変わりません。

### 手順

1. OCI コンソールか CLI で、`ap-osaka-1` リージョンの Oracle Linux 10 イメージ OCID を取得します:

```bash
oci compute image list --compartment-id ${TENANCY_OCID} --all --query "data[?contains(\"display-name\", 'Oracle-Linux-10') || contains(\"display-name\", 'Oracle Linux 10')].{id:id,displayName:\"display-name\"}"
```

2. 取得した OCID を `terraform.tfvars` に追加（既に設定済みの場合はスキップ）:

```hcl
image_ocid_oracle10_arm = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa3gpxiv2x5tradmcp4mbzhkh75otz4fqi5qsebxyhcjg2jzlmicna"
image_ocid_oracle10_amd = "ocid1.image.oc1.ap-osaka-1.aaaaaaaab255w2w7x57cgulwustekn77b6nhczbjpv4khefgmu2ejp2rh5ma"
```

3. 以下のコマンドで計画を生成します:

```bash
cd learn-terraform-oci
terraform init
terraform plan -out=oracle10.plan
```

**説明:** このコマンドは `source_id` の変更のみを検出し、3 リソース（ARM FW + AMD インスタンス 2台）の **イメージ参照の更新** をプランに含めます。ネットワーク構成・形状・固定IP・複数 VNIC（ARM FW の場合）は変わりません。

4. プランを確認し、問題なければ適用します:

```bash
terraform apply "oracle10.plan"
```

適用中はインスタンスが一時的に再起動される可能性があります。

### 注意

- この更新は **イメージの変更のみ** で、ネットワーク構成（VCN、Subnet、IGW、Route Table、Security List）や固定IP・VNIC構成は保持されます。
- 既存接続が一時的に切断される可能性があるため、本番環境での実行は計画的に行ってください。
- 複数リージョンを使用する場合は、各リージョンの Oracle Linux 10 OCID を取得して設定してください。
