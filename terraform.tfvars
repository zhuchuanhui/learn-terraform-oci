# =============================================================================
# terraform.tfvars
# 目的: 変数に実際の値を設定するファイル（機密情報はここに記載）
# 注意: このファイルはGitにコミットしないことを推奨（.gitignoreに追加）
# =============================================================================

tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaidabeh4bww766raesn274xyaormyuplogucdzg3fum4n43eyacja"
compartment_id   = "ocid1.tenancy.oc1..aaaaaaaaidabeh4bww766raesn274xyaormyuplogucdzg3fum4n43eyacja"
region           = "ap-osaka-1"
user_ocid        = "ocid1.user.oc1..aaaaaaaa7vxoipr6lwy2gq4fh3pycerljdhhkiobhszafl7zqc5k5kgpygrq"
fingerprint      = "c9:68:bb:43:b7:09:62:a5:b1:5a:2b:6f:08:f5:2a:62"
private_key_path = "/Users/d/.oci/d-oci.pem"
availability_domain = "ZXGQ:AP-OSAKA-1-AD-1"

# SSH公開キーをここに貼り付けてください（例: cat ~/.ssh/id_rsa.pub の内容）
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5mJkwhdDrCnpQGGcp3OkAVltI9OuagoJZxSyOiMIWSUKXm+nxkjuF8JWg0bq6heVMw3pFSbhrL1BJZuEQLDEqSio4XKO8RgYWBe5ALPzA+ARAr69zyLE1JbTm9X6zXc4ZPTZ7YRruedN9Csno7uoHOi3/yqsrupVRDPtIZGWLjSY6C5xuFTU5ds3Pp1WpFOuQuP8h3kRbIW2WF611NvMlwLbsZSPJpcMybsXwSUFA+ihwlfAscNNv5qaXSAfCQHF1ilWrCGLMRALaHwCNG5wQblL3L8kIIyNvXCDjF9Sl5U6+LOGn55rYJhWgtLoo630HhMn54PfD29nPqNJPNu1wTo16VbtOF9tq8Y+t82coZrE/SfV6xMTq0pJA962pFtcVyvOTp0J3cKnjG7+Gl4MlVvKketlhsngeZSJspfs+Ws8iTlcR0ilQu+BkaDbhVbTeZUWgqlt9RCk7v5ESqzJkPnYkvk1UHMSOyJ4D/A/XK0l2WFVqCFRxigsOcn1aFpvBvg6jQrAfXF14aKzSZ9ZMwUjM6bdWiPHI/G2Kj3Z2zT59QSVrknpkE25a57DFn+zj8xnuJVAfM5l016yluk9AsLQU2pZBInhY4jq7IBm0tcbkAOdWpFXTOEZfoHWUKYtUVEFZTwpkP3yEHU5bGLwLdBs8L21zXnw0ns/0gCQQoQ== d@D-MBP14.local"
