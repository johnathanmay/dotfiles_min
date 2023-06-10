#!/bin/sh

arch=`arch`
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
if ! type arkade; then
    notice "INSTALL arkade"
    curl -sLS https://get.arkade.dev | sh
    mv arkade $HOME/bin
    cd $HOME/bin
    ln -s arkade ark
    cd $INITIAL_DIR
fi

# install AWS CLI
if ! type aws; then
    notice "INSTALL aws cli v2"
    curl -sL "$url_aws" -o "${TMP_DIR}/awscliv2.zip"
    cd $TMP_DIR
    unzip -q awscliv2.zip
    sudo ./aws/install --update >> $LOG_FILE
    rm -rf ./awscliv2.zip ./aws
    cd $INITIAL_DIR
fi

# install kubectl
if ! type kubectl; then
    notice "INSTALL kubectl"
    curl -sL "$url_kubectl" -o "kubectl"
    sudo install kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# install yq
if ! type yq; then
    notice "INSTALL yq"
    curl -sL "$url_yq" -o "${TMP_DIR}/yq"
    chmod 755 "${TMP_DIR}/yq"
    sudo mv "${TMP_DIR}/yq" /usr/local/bin/yq
fi
