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

# Image OCIDs (set these in terraform.tfvars to Oracle Linux 9 images for your region)
variable "image_ocid_oracle9_arm" {
  description = "ARM用 Oracle Linux 9 イメージ OCID (ap-osaka-1)"
  type        = string
  default     = ""
}

variable "image_ocid_oracle9_amd" {
  description = "AMD用 Oracle Linux 9 イメージ OCID (ap-osaka-1)"
  type        = string
  default     = ""
}

# Image OCIDs for Oracle Linux 10
variable "image_ocid_oracle10_arm" {
  description = "ARM用 Oracle Linux 10 イメージ OCID (ap-osaka-1)"
  type        = string
  default     = ""
}

variable "image_ocid_oracle10_amd" {
  description = "AMD用 Oracle Linux 10 イメージ OCID (ap-osaka-1)"
  type        = string
  default     = ""
}
