#!/bin/bash -e
################################################################################
##  File:  install-powershell.sh
##  Desc:  Install PowerShell Core
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh

arch=$(get_arch)

if [[ $arch == "amd64" ]]; then
    arch="x64"
fi

pwsh_version=$(get_toolset_value .pwsh.version)

# Install Powershell
curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v$pwsh_version/powershell-$pwsh_version-linux-$arch.tar.gz
mkdir -p /opt/microsoft/powershell/7
tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
chmod +x /opt/microsoft/powershell/7/pwsh
ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
