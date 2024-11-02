variable "tenancy_ocid" {
  description = "ocid1.tenancy.oc1..aaaaaaaaidabeh4bww766raesn274xyaormyuplogucdzg3fum4n43eyacja" #OCIのテナントOCID
  type        = string
}

variable "compartment_id" {
  description = "ocid1.tenancy.oc1..aaaaaaaaidabeh4bww766raesn274xyaormyuplogucdzg3fum4n43eyacja" #OCIのテナントOCID
  type        = string
}

variable "region" {
  description = "region where you have OCI tenancy"
  type        = string
  default     = "ap-osaka-1"
}

variable "availability_domain" {
  description = "region where you have OCI tenancy"
  type        = string
  default     = "ZXGQ:AP-OSAKA-1-AD-1"
}

variable "user_ocid" {
  description = "ocid1.user.oc1..aaaaaaaa7vxoipr6lwy2gq4fh3pycerljdhhkiobhszafl7zqc5k5kgpygrq" #OCIユーザーのOCID
  type        = string
}

variable "fingerprint" {
  description = "c9:68:bb:43:b7:09:62:a5:b1:5a:2b:6f:08:f5:2a:62" #APIキーのフィンガープリント
  type        = string
}

variable "private_key_path" {
  description = "/Users/d/.oci/d-oci.pem" #プライベートキーのパス
  type        = string
}
