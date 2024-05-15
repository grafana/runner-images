#!/bin/bash -e
################################################################################
##  File:  install-mssql-tools.sh
##  Desc:  Install MS SQL Server client tools (https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-2017)
################################################################################

export ACCEPT_EULA=Y

apt-get update

source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh

arch=$(get_arch)

if [[ $arch == "amd64" ]]; then
  apt-get install -y mssql-tools unixodbc-dev
  apt-get -f install
  ln -s /opt/mssql-tools/bin/* /usr/local/bin/
fi

if [[ $arch == "arm64" ]]; then
  download_url=$(resolve_github_release_asset_url "microsoft/go-sqlcmd" "endswith(\"linux-$arch.tar.bz2\")" "latest")
  archive_path=$(download_with_retry "$download_url")
  tar -xjf $archive_path
  mv sqlcmd /usr/local/bin/sqlcmd
  mv sqlcmd_debug /usr/local/bin/sqlcmd_debug
fi

invoke_tests "Tools" "MSSQLCommandLineTools"
