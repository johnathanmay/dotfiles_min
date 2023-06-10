#!/bin/sh

TMP_DIR=/tmp
INITIAL_DIR=$(pwd)
LOG_FILE=$HOME/.jm_base_software.log

if [ "$1" = "-force" ]; then
    if [ -f $LOG_FILE ]; then rm $LOG_FILE; fi
else
    if [ -f $LOG_FILE ]; then return; fi
fi

notice() {
    echo "\n####################\n# $1\n####################\n"
}

sudo -l

##########
## install common system packages
##########
notice "INSTALL common system packages"
sudo apt-get update -qq
sudo apt-get install -y -q apt-file apt-transport-https atop build-essential curl debian-goodies dstat fzf git gocryptfs htop iotop ncal net-tools netstat-nat nicstat nmap openssh-server p7zip-full progress pwgen python3-venv tmux unzip vim whois wireguard-tools zsh >> $LOG_FILE

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

##########
## install desktop software
##########
if [ $XDG_SESSION_DESKTOP = "ubuntu" ]; then

    # install adoptium jdk
    notice "INSTALL Adoptium JDK 17"
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor > $TMP_DIR/packages.adoptium.gpg
    sudo install -o root -g root -m 644 $TMP_DIR/packages.adoptium.gpg /usr/share/keyrings/
    echo "deb [signed-by=/usr/share/keyrings/packages.adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
    sudo apt-get update -qq
    sudo apt-get install -y -q temurin-17-jdk >> $LOG_FILE

    # install powershell
    notice "INSTALL Powershell (pwsh)"
    curl -sL "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" -o /tmp/packages-microsoft-prod.deb
    sudo dpkg -i $TMP_DIR/packages-microsoft-prod.deb
    sudo rm $TMP_DIR/packages-microsoft-prod.deb
    sudo apt-get update -qq
    sudo apt-get install -y -q powershell >> $LOG_FILE

    # install system packages with GUI
    notice "INSTALL system packages with GUI"
    sudo apt-get install -y -q dconf-editor ffmpeg flatpak gnome-tweaks inxi libguestfs-tools neovim network-manager-l2tp-gnome ocrmypdf remmina totem ubuntu-restricted-extras virt-manager >> $LOG_FILE
    #sudo apt install -y gnome-shell-extension-manager solaar-gnome3 

    # apply ubuntu desktop preferences
    $HOME/bin/apply_ubuntu_desktop_preferences.sh

    # install gnome launchers
    $HOME/bin/install_gnome_launchers.sh

    # install 1password
    notice "INSTALL 1Password"
    if [ -f /usr/share/keyrings/1password-archive-keyring.gpg ]; then sudo rm /usr/share/keyrings/1password-archive-keyring.gpg; fi
    if [ -f /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg ]; then sudo rm /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg; fi
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
    sudo apt-get update -qq
    sudo apt-get install -y -qq 1password >> $LOG_FILE
    
    # install brave browser
    notice "INSTALL Brave"
    sudo apt install apt-transport-https curl
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt-get update -qq
    sudo apt-get install -y -q brave-browser >> $LOG_FILE
    
    # install google chrome
    notice "INSTALL Google Chrome"
    curl -sL "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -o $TMP_DIR/google-chrome-stable_current_amd64.deb
    sudo apt-get -y -q install /tmp/google-chrome-stable_current_amd64.deb >> $LOG_FILE
    rm /tmp/google-chrome-stable_current_amd64.deb
    
    # install [neovim](https://github.com/neovim/neovim/releases)
    notice "INSTALL neovim"
    curl -sL https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb -o $TMP_DIR/nvim-linux64.deb
    sudo apt-get install -y -q $TMP_DIR/nvim-linux64.deb >> $LOG_FILE
    sudo rm $TMP_DIR/nvim-linux64.deb
    
    # install vs code
    notice "INSTALL VS Code"
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > $TMP_DIR/packages.microsoft.gpg
    sudo install -o root -g root -m 644 $TMP_DIR/packages.microsoft.gpg /usr/share/keyrings/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt-get update -qq
    sudo apt-get install -y -q code >> $LOG_FILE
    cat ~/.dotfiles/vs_code_extensions |while read line; do
      /usr/bin/code --install-extension "$line"
    done

fi

notice "REMOVE unneeded packages"
sudo apt-get remove -y -q gstreamer1.0-vaapi
sudo apt-get autoremove -y -q

date +%Y%m%d%H%M >> $LOG_FILE
