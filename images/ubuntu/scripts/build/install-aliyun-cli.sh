#!/bin/bash -e
################################################################################
##  File:  install-aliyun-cli.sh
##  Desc:  Install Alibaba Cloud CLI
##  Supply chain security: Alibaba Cloud CLI - checksum validation
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/install.sh

arch=$(get_arch)

# Install Alibaba Cloud CLI
# Pin tool version on ubuntu20 due to issues with GLIBC_2.32 not available
if is_ubuntu20; then
    toolset_version=$(get_toolset_value '.aliyunCli.version')
    download_url="https://github.com/aliyun/aliyun-cli/releases/download/v$toolset_version/aliyun-cli-linux-$toolset_version-$arch.tgz"
else
    download_url=$(resolve_github_release_asset_url "aliyun/aliyun-cli" "contains(\"aliyun-cli-linux\") and endswith(\"$arch.tgz\")" "latest")
    hash_url="https://github.com/aliyun/aliyun-cli/releases/latest/download/SHASUMS256.txt"
fi

archive_path=$(download_with_retry "$download_url")

# Supply chain security - Alibaba Cloud CLI
if is_ubuntu20; then
    external_hash=$(get_toolset_value ".aliyunCli.sha256.$arch")
else
    external_hash=$(get_checksum_from_url "$hash_url" "aliyun-cli-linux.*$arch.tgz" "SHA256")
fi

use_checksum_comparison "$archive_path" "$external_hash"

tar xzf "$archive_path"
mv aliyun /usr/local/bin

invoke_tests "CLI.Tools" "Aliyun CLI"
