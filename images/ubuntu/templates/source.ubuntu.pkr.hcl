source "azure-arm" "image" {
  client_cert_path                       = var.client_cert_path
  client_id                              = var.client_id
  client_secret                          = var.client_secret
  object_id                              = var.object_id
  oidc_request_token                     = var.oidc_request_token
  oidc_request_url                       = var.oidc_request_url
  subscription_id                        = var.subscription_id
  tenant_id                              = var.tenant_id
  use_azure_cli_auth                     = var.use_azure_cli_auth

  allowed_inbound_ip_addresses           = var.allowed_inbound_ip_addresses
  build_resource_group_name              = var.build_resource_group_name
  image_offer                            = local.image_properties.offer
  image_publisher                        = local.image_properties.publisher
  image_sku                              = local.image_properties.sku
  image_version                          = var.source_image_version
  location                               = var.location
  managed_image_name                     = var.managed_image_name
  managed_image_resource_group_name      = var.managed_image_resource_group_name
  managed_image_storage_account_type     = var.managed_image_storage_account_type
  os_disk_size_gb                        = local.image_properties.os_disk_size_gb
  os_type                                = var.image_os_type
  private_virtual_network_with_public_ip = var.private_virtual_network_with_public_ip
  ssh_clear_authorized_keys              = var.ssh_clear_authorized_keys
  temp_resource_group_name               = var.temp_resource_group_name
  virtual_network_name                   = var.virtual_network_name
  virtual_network_resource_group_name    = var.virtual_network_resource_group_name
  virtual_network_subnet_name            = var.virtual_network_subnet_name
  vm_size                                = var.vm_size
  winrm_username                         = var.winrm_username

  shared_image_gallery_destination {
    subscription                         = var.subscription_id
    gallery_name                         = var.gallery_name
    resource_group                       = var.gallery_resource_group_name
    image_name                           = var.gallery_image_name
    image_version                        = var.gallery_image_version
    storage_account_type                 = var.gallery_storage_account_type
  }

  dynamic "azure_tag" {
    for_each = var.azure_tags
    content {
      name  = azure_tag.key
      value = azure_tag.value
    }
  }
}


source "amazon-ebs" "build_image" {
  aws_polling {
    delay_seconds = 30
    max_attempts  = 300
  }

  temporary_security_group_source_public_ip = true
  ami_name                                  = "${local.managed_image_name}"
  ami_virtualization_type                   = "hvm"
  ami_groups                                = var.aws_private_ami ? [] : ["all"]
  ebs_optimized                             = true
  instance_type                             = local.aws_instance_type
  region                                    = "${var.aws_region}"
  ssh_username                              = "ubuntu"
  subnet_id                                 = "${var.aws_subnet_id}"
  associate_public_ip_address               = "true"
  force_deregister                          = "${var.aws_force_deregister}"
  force_delete_snapshot                     = "${var.aws_force_deregister}"

  ami_regions = [
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
  ]

  snapshot_groups = var.aws_private_ami ? [] : ["all"]

  tags = var.aws_tags

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_type = "${var.aws_volume_type}"
    volume_size = "${var.aws_volume_size}"
    delete_on_termination = "true"
    iops = 6000
    throughput = 1000
    encrypted = "false"
  }

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "${local.aws_source_image_name}"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  assume_role {
    role_arn     = "${var.aws_assume_role_arn}"
    session_name = "${var.aws_assume_role_session_name}"
    tags = {
      event_name = "${var.github_event_name}"
      repository_owner = "${var.github_repository_owner}"
      repository_name = "${var.github_repository_name}"
      job_workflow_ref = "${var.github_job_workflow_ref}"
      ref = "${var.github_ref}"
    }
  }
}
