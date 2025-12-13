# =============================================================================
# variables.tf
# 目的: Terraformで使用するすべての変数を宣言
# 注意: main.tf や instance.tf で使用している変数はここに必ず宣言する必要があります
# =============================================================================

variable "tenancy_ocid" {
  description = "OCIテナンシーOCID"
  type        = string
}

variable "compartment_id" {
  description = "OCIコンパートメントOCID（ルートコンパートメント）"
  type        = string
}

variable "region" {
  description = "使用するOCIリージョン"
  type        = string
  default     = "ap-osaka-1"
}

variable "user_ocid" {
  description = "OCIユーザーOCID"
  type        = string
}

variable "fingerprint" {
  description = "APIキーのフィンガープリント"
  type        = string
}

variable "private_key_path" {
  description = "API署名用プライベートキーのパス"
  type        = string
}

variable "ssh_public_key" {
  description = "インスタンスに設定するSSH公開キー（全文）"
  type        = string
  sensitive   = true
}

variable "availability_domain" {
  description = "インスタンスの可用性ドメイン"
  type        = string
  default     = "ZXGQ:AP-OSAKA-1-AD-1"
}
