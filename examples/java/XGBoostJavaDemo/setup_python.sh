#!/usr/bin/env bash

set -e  # Exit on any error
set -o pipefail

##########
# Detect OS
OS=$(uname -s)

##########
# Function to set up pyenv in the current shell
setup_pyenv_env() {
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}

##########
sudo apt -y update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev git apt-transport-https ca-certificates gnupg

  # Install pyenv if not present
if which pyenv &>/dev/null; then
    echo "pyenv is already installed"
else
    echo "Installing pyenv..."
    curl https://pyenv.run | bash

    # Add to ~/.bashrc
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
fi

setup_pyenv_env

##########
# Python environment setup

# Install Python version (skip if already installed)
if pyenv versions --bare | grep -q "^3.9.22$"; then
  echo "Python 3.9.22 is already installed"
else
  echo "Installing Python 3.9.22..."
  pyenv install 3.9.22
fi

pyenv global 3.9.22
