#!/bin/bash -e
################################################################################
##  File:  install-miniconda.sh
##  Desc:  Install miniconda
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/etc-environment.sh
source $HELPER_SCRIPTS/os.sh

arch=$(get_arch)

if [[ $arch == "amd64" ]]; then
    arch="x86_64"
fi

if [[ $arch == "arm64" ]]; then
    arch="aarch64"
fi

# Install Miniconda
curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$arch.sh -o miniconda.sh \
    && chmod +x miniconda.sh \
    && ./miniconda.sh -b -p /usr/share/miniconda \
    && rm miniconda.sh

CONDA=/usr/share/miniconda
set_etc_environment_variable "CONDA" "${CONDA}"

ln -s $CONDA/bin/conda /usr/bin/conda

invoke_tests "Tools" "Conda"
