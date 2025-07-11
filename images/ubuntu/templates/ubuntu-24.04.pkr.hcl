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
  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
  image_version =  "${var.image_version}-${local.timestamp}"
  managed_image_name = var.managed_image_name != "" ? var.managed_image_name : "packer-${var.image_os}-${local.image_version}"
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
  default = "${env("BUILD_RG_NAME")}"
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

variable "dockerhub_login" {
  type    = string
  default = "${env("DOCKERHUB_LOGIN")}"
}

variable "dockerhub_password" {
  type    = string
  default = "${env("DOCKERHUB_PASSWORD")}"
}

variable "helper_script_folder" {
  type    = string
  default = "/imagegeneration/helpers"
}

variable "image_folder" {
  type    = string
  default = "/imagegeneration"
}

variable "image_os" {
  type    = string
  default = "ubuntu24"
}

variable "image_version" {
  type    = string
  default = "dev"
}

variable "imagedata_file" {
  type    = string
  default = "/imagegeneration/imagedata.json"
}

variable "installer_script_folder" {
  type    = string
  default = "/imagegeneration/installers"
}

variable "install_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "azure_location" {
  type    = string
  default = ""
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
  default = 80
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

variable "github_ref" {
  type    = string
  default = "${env("GITHUB_REF")}"
}

source "azure-arm" "build_image" {
  allowed_inbound_ip_addresses           = "${var.azure_allowed_inbound_ip_addresses}"
  build_resource_group_name              = "${var.azure_build_resource_group_name}"
  client_cert_path                       = "${var.azure_client_cert_path}"
  client_id                              = "${var.azure_client_id}"
  client_secret                          = "${var.azure_client_secret}"
  image_offer                            = "ubuntu-24_04-lts"
  image_publisher                        = "canonical"
  image_sku                              = "server-gen1"
  location                               = "${var.azure_location}"
  managed_image_name                     = "${local.managed_image_name}"
  managed_image_resource_group_name      = "${var.azure_managed_image_resource_group_name}"
  os_disk_size_gb                        = "75"
  os_type                                = "Linux"
  private_virtual_network_with_public_ip = "${var.azure_private_virtual_network_with_public_ip}"
  subscription_id                        = "${var.azure_subscription_id}"
  temp_resource_group_name               = "${var.azure_temp_resource_group_name}"
  tenant_id                              = "${var.azure_tenant_id}"
  virtual_network_name                   = "${var.azure_virtual_network_name}"
  virtual_network_resource_group_name    = "${var.azure_virtual_network_resource_group_name}"
  virtual_network_subnet_name            = "${var.azure_virtual_network_subnet_name}"
  vm_size                                = "${var.azure_vm_size}"

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
  spot_instance_types                       = ["m7i.xlarge", "m6i.xlarge"]
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
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
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

build {
  sources = ["source.${local.cloud_providers[var.provider]}.build_image"]

  post-processor "manifest" {
    output = "${path.root}/../build-manifest.json"
    strip_path = true
    custom_data = {
      image_name    = "${local.managed_image_name}"
    }
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = ["mkdir ${var.image_folder}", "chmod 777 ${var.image_folder}"]
  }

  provisioner "file" {
    destination = "${var.helper_script_folder}"
    source      = "${path.root}/../scripts/helpers"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script          = "${path.root}/../scripts/build/configure-apt-mock.sh"
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}","DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = [
      "${path.root}/../scripts/build/install-ms-repos.sh",
      "${path.root}/../scripts/build/configure-apt-sources.sh",
      "${path.root}/../scripts/build/configure-apt.sh"
    ]
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script          = "${path.root}/../scripts/build/configure-limits.sh"
  }

  provisioner "file" {
    destination = "${var.installer_script_folder}"
    source      = "${path.root}/../scripts/build"
  }

  provisioner "file" {
    destination = "${var.image_folder}"
    sources     = [
      "${path.root}/../assets/post-gen",
      "${path.root}/../scripts/tests",
      "${path.root}/../scripts/docs-gen"
    ]
  }

  provisioner "file" {
    destination = "${var.image_folder}/docs-gen/"
    source      = "${path.root}/../../../helpers/software-report-base"
  }

  provisioner "file" {
    destination = "${var.installer_script_folder}/toolset.json"
    source      = "${path.root}/../toolsets/toolset-2404.json"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = [
      "mv ${var.image_folder}/docs-gen ${var.image_folder}/SoftwareReport",
      "mv ${var.image_folder}/post-gen ${var.image_folder}/post-generation"
    ]
  }

  provisioner "shell" {
    environment_vars = ["IMAGE_VERSION=${var.image_version}", "IMAGEDATA_FILE=${var.imagedata_file}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/configure-image-data.sh"]
  }

  provisioner "shell" {
    environment_vars = ["IMAGE_VERSION=${var.image_version}", "IMAGE_OS=${var.image_os}", "HELPER_SCRIPTS=${var.helper_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/configure-environment.sh"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/install-apt-vital.sh"]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/install-powershell.sh"]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} pwsh -f {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/Install-PowerShellModules.ps1", "${path.root}/../scripts/build/Install-PowerShellAzModules.ps1"]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}", "DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = [
      "${path.root}/../scripts/build/install-actions-cache.sh",
      "${path.root}/../scripts/build/install-runner-package.sh",
      "${path.root}/../scripts/build/install-apt-common.sh",
      "${path.root}/../scripts/build/install-azcopy.sh",
      "${path.root}/../scripts/build/install-azure-cli.sh",
      "${path.root}/../scripts/build/install-azure-devops-cli.sh",
      "${path.root}/../scripts/build/install-bicep.sh",
      "${path.root}/../scripts/build/install-apache.sh",
      "${path.root}/../scripts/build/install-aws-tools.sh",
      "${path.root}/../scripts/build/install-clang.sh",
      "${path.root}/../scripts/build/install-swift.sh",
      "${path.root}/../scripts/build/install-cmake.sh",
      "${path.root}/../scripts/build/install-codeql-bundle.sh",
      "${path.root}/../scripts/build/install-container-tools.sh",
      "${path.root}/../scripts/build/install-dotnetcore-sdk.sh",
      "${path.root}/../scripts/build/install-microsoft-edge.sh",
      "${path.root}/../scripts/build/install-gcc-compilers.sh",
      "${path.root}/../scripts/build/install-firefox.sh",
      "${path.root}/../scripts/build/install-gfortran.sh",
      "${path.root}/../scripts/build/install-git.sh",
      "${path.root}/../scripts/build/install-git-lfs.sh",
      "${path.root}/../scripts/build/install-github-cli.sh",
      "${path.root}/../scripts/build/install-google-chrome.sh",
      "${path.root}/../scripts/build/install-google-cloud-cli.sh",
      "${path.root}/../scripts/build/install-haskell.sh",
      "${path.root}/../scripts/build/install-java-tools.sh",
      "${path.root}/../scripts/build/install-kubernetes-tools.sh",
      "${path.root}/../scripts/build/install-miniconda.sh",
      "${path.root}/../scripts/build/install-kotlin.sh",
      "${path.root}/../scripts/build/install-mysql.sh",
      "${path.root}/../scripts/build/install-nginx.sh",
      "${path.root}/../scripts/build/install-nvm.sh",
      "${path.root}/../scripts/build/install-nodejs.sh",
      "${path.root}/../scripts/build/install-bazel.sh",
      "${path.root}/../scripts/build/install-php.sh",
      "${path.root}/../scripts/build/install-postgresql.sh",
      "${path.root}/../scripts/build/install-pulumi.sh",
      "${path.root}/../scripts/build/install-ruby.sh",
      "${path.root}/../scripts/build/install-rust.sh",
      "${path.root}/../scripts/build/install-julia.sh",
      "${path.root}/../scripts/build/install-selenium.sh",
      "${path.root}/../scripts/build/install-packer.sh",
      "${path.root}/../scripts/build/install-vcpkg.sh",
      "${path.root}/../scripts/build/configure-dpkg.sh",
      "${path.root}/../scripts/build/install-yq.sh",
      "${path.root}/../scripts/build/install-android-sdk.sh",
      "${path.root}/../scripts/build/install-pypy.sh",
      "${path.root}/../scripts/build/install-python.sh",
      "${path.root}/../scripts/build/install-zstd.sh",
      "${path.root}/../scripts/build/install-ninja.sh"
    ]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}", "DOCKERHUB_PULL_IMAGES=NO"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/install-docker.sh"]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} pwsh -f {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/Install-Toolset.ps1", "${path.root}/../scripts/build/Configure-Toolset.ps1"]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/install-pipx-packages.sh"]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "DEBIAN_FRONTEND=noninteractive", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = "/bin/sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/install-homebrew.sh"]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/configure-snap.sh"]
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
    environment_vars = ["IMAGE_VERSION=${var.image_version}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    inline           = ["pwsh -File ${var.image_folder}/SoftwareReport/Generate-SoftwareReport.ps1 -OutputDirectory ${var.image_folder}", "pwsh -File ${var.image_folder}/tests/RunAll-Tests.ps1 -OutputDirectory ${var.image_folder}"]
  }

  provisioner "file" {
    destination = "${path.root}/../software-report.md"
    direction   = "download"
    source      = "${var.image_folder}/software-report.md"
  }

  provisioner "file" {
    destination = "${path.root}/../software-report.json"
    direction   = "download"
    source      = "${var.image_folder}/software-report.json"
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPT_FOLDER=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}", "IMAGE_FOLDER=${var.image_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/configure-system.sh"]
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = ["sleep 30", "test '${var.provider}' = 'azure' && /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync || echo 'Not Azure'"]
  }

}
