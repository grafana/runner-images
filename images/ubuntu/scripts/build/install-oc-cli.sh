#!/bin/bash -e
################################################################################
##  File:  install-oc-cli.sh
##  Desc:  Install the OC CLI
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh

arch=$(get_arch)
suffix=""

if [[ $arch == "arm64" ]]; then
    suffix="-arm64"
fi

# Install the oc CLI
archive_path=$(download_with_retry "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux$suffix.tar.gz")
tar xzf "$archive_path" -C "/usr/local/bin" oc

invoke_tests "CLI.Tools" "OC CLI"
