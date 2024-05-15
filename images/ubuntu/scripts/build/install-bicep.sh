#!/bin/bash -e
################################################################################
##  File:  install-bicep.sh
##  Desc:  Install bicep cli
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh

arch=$(get_arch)

if [[ $arch == "amd64" ]]; then
    arch="x64"
fi

# Install Bicep CLI
download_url=$(resolve_github_release_asset_url "Azure/bicep" "endswith(\"bicep-linux-$arch\")" "latest")
bicep_binary_path=$(download_with_retry "${download_url}")

# Mark it as executable
install "$bicep_binary_path" /usr/local/bin/bicep

invoke_tests "Tools" "Bicep"
