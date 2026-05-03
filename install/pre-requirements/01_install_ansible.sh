#!/bin/bash

# Default values
VENV_NAME=""
VENV_PATH="."
ANSIBLE_DEV_VERSION=""

# Usage help
usage() {
    echo "Usage: $0 [-n <venv_name>] [-p <path>] [-v <version>]"
    echo "  -n : Name of the virtual environment (Optional, default: ansible-dev-tools-XXXXX)"
    echo "  -p : Path to create the venv (Default: current directory)"
    echo "  -v : Version of ansible-dev-tools to install (Default: latest)"
    exit 1
}

# Parse flags
while getopts "n:p:v:" opt; do
    case $opt in
        n) VENV_NAME=$OPTARG ;;
        p) VENV_PATH=$OPTARG ;;
        v) ANSIBLE_DEV_VERSION=$OPTARG ;;
        *) usage ;;
    esac
done

# Generate automatic name if none provided
if [ -z "$VENV_NAME" ]; then
    SUFFIX=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)
    VENV_NAME="ansible-dev-tools-$SUFFIX"
    echo "No name provided. Generated name: $VENV_NAME"
fi

FULL_PATH="${VENV_PATH}/${VENV_NAME}"

echo "Creating virtual environment at: $FULL_PATH"

# Create directory if it doesn't exist
mkdir -p "$VENV_PATH"

# Create virtualenv
python3 -m venv "$FULL_PATH"

# Activate virtualenv
source "$FULL_PATH/bin/activate"

# Upgrade pip
pip install --upgrade pip

# Install ansible-dev-tools
if [ -z "$ANSIBLE_DEV_VERSION" ]; then
    echo "Installing latest version of ansible-dev-tools..."
    pip install ansible-dev-tools
else
    echo "Installing ansible-dev-tools version: $ANSIBLE_DEV_VERSION..."
    pip install "ansible-dev-tools==$ANSIBLE_DEV_VERSION"
fi

echo "------------------------------------------------"
echo "Setup complete"
