#!/bin/bash -e
################################################################################
##  File:  install-oc-cli.sh
##  Desc:  Install the OC CLI
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh

arch=$(get_arch)
suffix=""

if [[ $arch == "arm64" ]]; then
    suffix="-arm64"
fi

if is_ubuntu20; then
    toolset_version=$(get_toolset_value '.ocCli.version')
    download_url="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$toolset_version/openshift-client-linux-$toolset_version.tar.gz"
else 
    # Install the oc CLI
    archive_path=$(download_with_retry "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux$suffix.tar.gz")
fi

archive_path=$(download_with_retry "$download_url")

tar xzf "$archive_path" -C "/usr/local/bin" oc

invoke_tests "CLI.Tools" "OC CLI"
