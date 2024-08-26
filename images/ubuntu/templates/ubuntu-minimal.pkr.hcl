packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "1.4.5"
    }
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

locals {
  image_os = "ubuntu22"

  toolset_file_name = "toolset-2204.json"

  image_folder            = "/imagegeneration"
  helper_script_folder    = "/imagegeneration/helpers"
  installer_script_folder = "/imagegeneration/installers"
  imagedata_file          = "/imagegeneration/imagedata.json"

  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
  image_version =  "${var.image_version}-${local.timestamp}"
  managed_image_name = var.managed_image_name != "" ? var.managed_image_name : "packer-${local.image_os}-${local.image_version}"
  cloud_providers = {
    "aws" = "amazon-ebs",
    "azure"  = "azure-arm"
  }
}

variable "provider" {
  type    = string
}

variable "azure_allowed_inbound_ip_addresses" {
  type    = list(string)
  default = []
}

variable "azure_tags" {
  type    = map(string)
  default = {}
}

variable "azure_build_resource_group_name" {
  type    = string
  default = "${env("BUILD_RESOURCE_GROUP_NAME")}"
}

variable "azure_client_cert_path" {
  type    = string
  default = "${env("ARM_CLIENT_CERT_PATH")}"
}

variable "azure_client_id" {
  type    = string
  default = "${env("ARM_CLIENT_ID")}"
}

variable "azure_client_secret" {
  type      = string
  default   = "${env("ARM_CLIENT_SECRET")}"
  sensitive = true
}

variable "image_version" {
  type    = string
  default = "dev"
}

variable "install_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "azure_location" {
  type    = string
  default = "${env("ARM_RESOURCE_LOCATION")}"
}

variable "managed_image_name" {
  type    = string
  default = ""
}

variable "azure_managed_image_resource_group_name" {
  type    = string
  default = "${env("ARM_RESOURCE_GROUP")}"
}

variable "azure_private_virtual_network_with_public_ip" {
  type    = bool
  default = false
}

variable "azure_subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

variable "azure_temp_resource_group_name" {
  type    = string
  default = "${env("TEMP_RESOURCE_GROUP_NAME")}"
}

variable "azure_tenant_id" {
  type    = string
  default = "${env("ARM_TENANT_ID")}"
}

variable "azure_virtual_network_name" {
  type    = string
  default = "${env("VNET_NAME")}"
}

variable "azure_virtual_network_resource_group_name" {
  type    = string
  default = "${env("VNET_RESOURCE_GROUP")}"
}

variable "azure_virtual_network_subnet_name" {
  type    = string
  default = "${env("VNET_SUBNET")}"
}

variable "azure_vm_size" {
  type    = string
  default = "Standard_D4s_v4"
}

variable "aws_subnet_id" {
  type    = string
  default = "${env("SUBNET_ID")}"
}

variable "aws_volume_size" {
  type    = number
  default = 75
}

variable "aws_volume_type" {
  type    = string
  default = "gp3"
}

variable "aws_region" {
  type    = string
  default = "${env("AWS_DEFAULT_REGION")}"
}

variable "aws_tags" {
  type    = map(string)
  default = {}
}

variable "aws_private_ami" {
  type    = bool
  default = false
}

variable "aws_force_deregister" {
  type    = bool
  default = false
}

variable "aws_assume_role_arn" {
  type    = string
  default = ""
}

variable "aws_assume_role_session_name" {
  type    = string
  default = ""
}

variable "github_event_name" {
  type    = string
  default = "${env("GITHUB_EVENT_NAME")}"
}

variable "github_repository_owner" {
  type    = string
  default = "${env("GITHUB_REPOSITORY_OWNER")}"
}

variable "github_repository_name" {
  type    = string
  default = "${env("GITHUB_REPOSITORY_NAME")}"
}

variable "github_job_workflow_ref" {
  type    = string
  default = "${env("GITHUB_JOB_WORKFLOW_REF")}"
}

source "azure-arm" "build_image" {
  location = "${var.azure_location}"

  // Auth
  tenant_id        = "${var.azure_tenant_id}"
  subscription_id  = "${var.azure_subscription_id}"
  client_id        = "${var.azure_client_id}"
  client_secret    = "${var.azure_client_secret}"
  client_cert_path = "${var.azure_client_cert_path}"

  // Base image
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_publisher = "canonical"
  image_sku       = "22_04-lts"

  // Target location
  managed_image_name = "${local.managed_image_name}"
  managed_image_resource_group_name = "${var.azure_managed_image_resource_group_name}"

  // Resource group for VM
  build_resource_group_name = "${var.azure_build_resource_group_name}"
  temp_resource_group_name  = "${var.azure_temp_resource_group_name}"

  // Networking for VM
  private_virtual_network_with_public_ip = "${var.azure_private_virtual_network_with_public_ip}"
  virtual_network_resource_group_name    = "${var.azure_virtual_network_resource_group_name}"
  virtual_network_name                   = "${var.azure_virtual_network_name}"
  virtual_network_subnet_name            = "${var.azure_virtual_network_subnet_name}"
  allowed_inbound_ip_addresses           = "${var.azure_allowed_inbound_ip_addresses}"

  // VM Configuration
  vm_size         = "${var.azure_vm_size}"
  os_disk_size_gb = "75"
  os_type         = "Linux"

  dynamic "azure_tag" {
    for_each = var.azure_tags
    content {
      name = azure_tag.key
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
  spot_instance_types                       = ["t3.xlarge"]
  spot_price                                = "1.00"
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

  // make underlying snapshot public
  snapshot_groups = ["all"]

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
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
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
    }
  }
}

build {
  sources = ["source.${local.cloud_providers[var.provider]}.build_image"]

  // Create folder to store temporary data
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = ["mkdir ${local.image_folder}", "chmod 777 ${local.image_folder}"]
  }

  provisioner "file" {
    destination = "${local.helper_script_folder}"
    source      = "${path.root}/../scripts/helpers"
  }

  // Add apt wrapper to implement retries
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script          = "${path.root}/../scripts/build/configure-apt-mock.sh"
  }

  // Install MS package repos, Configure apt
  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${local.helper_script_folder}","DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = [
      "${path.root}/../scripts/build/install-ms-repos.sh",
      "${path.root}/../scripts/build/configure-apt.sh"
    ]
  }

  // Configure limits
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script          = "${path.root}/../scripts/build/configure-limits.sh"
  }

  provisioner "file" {
    destination = "${local.installer_script_folder}"
    source      = "${path.root}/../scripts/build"
  }

  provisioner "file" {
    destination = "${local.image_folder}"
    sources     = [
      "${path.root}/../assets/post-gen",
      "${path.root}/../scripts/tests"
    ]
  }

  provisioner "file" {
    destination = "${local.installer_script_folder}/toolset.json"
    source      = "${path.root}/../toolsets/${local.toolset_file_name}"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = ["mv ${local.image_folder}/post-gen ${local.image_folder}/post-generation"]
  }

  // Generate image data file
  provisioner "shell" {
    environment_vars = ["IMAGE_VERSION=${var.image_version}", "IMAGEDATA_FILE=${local.imagedata_file}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/configure-image-data.sh"]
  }

  // Create /etc/environment, configure waagent etc.
  provisioner "shell" {
    environment_vars = ["IMAGE_VERSION=${var.image_version}", "IMAGE_OS=${local.image_os}", "HELPER_SCRIPTS=${local.helper_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/configure-environment.sh"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "HELPER_SCRIPTS=${local.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${local.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/install-apt-vital.sh"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "HELPER_SCRIPTS=${local.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${local.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/install-powershell.sh"]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${local.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${local.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} pwsh -f {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/Install-PowerShellModules.ps1"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "HELPER_SCRIPTS=${local.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${local.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = [
      "${path.root}/../scripts/build/install-git.sh",
      "${path.root}/../scripts/build/install-git-lfs.sh",
      "${path.root}/../scripts/build/install-github-cli.sh",
      "${path.root}/../scripts/build/install-zstd.sh"
    ]
  }

  provisioner "shell" {
    execute_command   = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    expect_disconnect = true
    inline            = ["echo 'Reboot VM'", "sudo reboot"]
  }

  provisioner "shell" {
    execute_command     = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    pause_before        = "1m0s"
    scripts             = ["${path.root}/../scripts/build/cleanup.sh"]
    start_retry_timeout = "10m"
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPT_FOLDER=${local.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${local.installer_script_folder}", "IMAGE_FOLDER=${local.image_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/configure-system.sh"]
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = ["sleep 30", "test '${var.provider}' = 'azure' && /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync || echo 'Not Azure'"]
  }

}
