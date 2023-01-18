#!/usr/bin/bash
set -euo pipefail

function step(){
  echo "$(tput setaf 10)$1$(tput sgr0)"
}

Port="${1:-22}"

step "Set locale"
sudo locale-gen en_US.UTF-8
sudo locale-gen zh_TW.UTF-8
export LC_ALL=en_US.UTF-8

step "Update all packages"
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

step "Stop unattended upgrade"
sudo sed -E 's;APT::Periodic::Unattended-Upgrade "1"\;;APT::Periodic::Unattended-Upgrade "0"\;;g' -i /etc/apt/apt.conf.d/20auto-upgrades

step "Configuring git"
git config --global pull.rebase false

step "Get useful commands"
sudo apt update
sudo apt install -y git curl zsh wget htop vim tree openssh-server lm-sensors \
                    cmake tmux python3-pip python-is-python3
sudo apt install -y clang clang-tools
sudo apt install -y python3-packaging # To build from source of TensorFlow


step "Get oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

step "Get Oh my tmux"
git clone https://github.com/gpakosz/.tmux.git ${HOME}/.tmux
ln -s -f ${HOME}/.tmux/.tmux.conf ${HOME}

step "Copy environment"
sudo chsh -s /usr/bin/zsh ${USER}
cp .p10k.zsh .zshrc .tmux.conf.local ${HOME}/

step "Get conda"
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
eval "$(${HOME}/miniconda/bin/conda shell.bash hook)"
conda init zsh
conda config --set auto_activate_base false

step "Install nodejs, yarn & bazelisk"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt update
sudo apt install -y nodejs
sudo corepack enable
yarn init -2
sudo npm install -g @bazel/bazelisk

step "Install Podman"
sudo apt update
sudo apt upgrade -y
sudo apt install -y podman
sudo sed -E 's;# unqualified-search-registries = \["example.com"\];unqualified-search-registries = \["docker.io"\];1' -i /etc/containers/registries.conf

step "clean up"
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean
