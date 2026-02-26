locals {
  image_properties_map = {
      "ubuntu22" = {
            source_image_marketplace_sku = "canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2"
            os_disk_size_gb = 75
      },
      "ubuntu24" = {
            source_image_marketplace_sku = "canonical:ubuntu-24_04-lts:server"
            os_disk_size_gb = 75
      }
  }

  image_properties = local.image_properties_map[var.image_os]

  aws_instance_type_map = {
    "amd64" = "m7i.xlarge"
    "arm64" = "m7g.xlarge"
  }

  aws_source_image_name_map = {
    "ubuntu22" = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-${var.image_arch}-server-*"
    "ubuntu24" = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-${var.image_arch}-server-*"
  }

  aws_source_image_name = local.aws_source_image_name_map[var.image_os]
  aws_instance_type = local.aws_instance_type_map[var.image_arch]

  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
  image_version =  "${var.image_version}-${local.timestamp}"
  managed_image_name = var.managed_image_name != "" ? var.managed_image_name : "packer-${var.image_os}-${var.image_arch}-${local.image_version}"
  cloud_providers = {
    "aws" = "amazon-ebs",
    "azure"  = "azure-arm"
  }
  
  source_image_marketplace_sku = local.image_properties_map[var.image_os].source_image_marketplace_sku
  os_disk_size_gb = coalesce(var.os_disk_size_gb, local.image_properties_map[var.image_os].os_disk_size_gb)
}
