#!/bin/sh

TMP_DIR="/tmp"
INITIAL_DIR=$(pwd)
LOG_FILE=$HOME/.install_common_binaries.log

echo $(date +%Y%m%d%H%M) >> $LOG_FILE

notice() {
    echo "\n####################\n# $1\n####################\n"
}

if [ "$1" = "-f" ]; then
    FORCE="true"
fi

arch=$(arch)
if [ "$arch" = "amd64" ] || [ "$arch" = "x86_64" ]; then
    url_aws="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    url_kubectl="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    url_yq="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64"
else
    url_aws="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
    url_kubectl="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
    url_yq="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64"
fi

# install [arkade](https://github.com/alexellis/arkade)
if ! type arkade || $FORCE = "true"; then
    notice "INSTALL arkade"
    curl -sLS https://get.arkade.dev | sh
    mv arkade $HOME/bin
    cd $HOME/bin
    ln -s arkade ark
    cd $INITIAL_DIR
fi

# install AWS CLI
if ! type aws || $FORCE = "true"; then
    notice "INSTALL aws cli v2"
    curl -sL "$url_aws" -o "${TMP_DIR}/awscliv2.zip"
    cd $TMP_DIR
    unzip -q awscliv2.zip
    AWS_VER=$(./aws/dist/aws --version |awk '{print $1}' |awk -F/ '{print $2}')
    sudo ./aws/install --update >> $LOG_FILE
    aws --version >> $LOG_FILE
    rm -rf ./awscliv2.zip ./aws
    cd $INITIAL_DIR
fi

# install kubectl
if ! type kubectl || $FORCE = "true"; then
    notice "INSTALL kubectl"
    curl -sL "$url_kubectl" -o "kubectl"
    sudo install kubectl /usr/local/bin/kubectl
    chmod +x ./kubectl
    ./kubectl version >> $LOG_FILE
    rm kubectl
fi

# install yq
if ! type yq || $FORCE = "true"; then
    notice "INSTALL yq"
    curl -sL "$url_yq" -o "${TMP_DIR}/yq"
    chmod 755 "${TMP_DIR}/yq"
    sudo mv "${TMP_DIR}/yq" /usr/local/bin/yq
fi
