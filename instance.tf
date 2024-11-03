

#インポート済みリソース
resource "oci_core_instance" "existing_instance" { #ARM device
  compartment_id   = var.compartment_id
  availability_domain = var.availability_domain
  # インポート後に情報がここに挿入してください
}

resource "oci_core_instance" "existing_instance1" { #AMD device1
  compartment_id   = var.compartment_id
  availability_domain = var.availability_domain
  # インポート後に情報がここに挿入してください
}

resource "oci_core_instance" "existing_instance2" { #AMD device2
  compartment_id   = var.compartment_id
  availability_domain = var.availability_domain
  # インポート後に情報がここに挿入してください
}
