# =============================================================================
# main.tf
# 目的: Terraformのプロバイダー設定（OCI接続情報）を定義するメイン設定ファイル
# 内容: OCIプロバイダーの認証情報と基本設定のみを記述
# 注意: リソース定義は他のファイル（instance.tfなど）に分離しています
# =============================================================================

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"  # 最新安定版を推奨
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
