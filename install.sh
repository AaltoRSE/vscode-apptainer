#!/bin/bash

REPO_URL="aaltorse/vscode-apptainer"

# Find all release tags of vscode-apptainer repository and use the most recent as $LATEST_TAG
LATEST_TAG=$(curl -s https://api.github.com/repos/$REPO_URL/tags | grep 'name' | head -n 1 | cut -d '"' -f 4)
if [ -z "$LATEST_TAG" ]; then
	echo "Could not fetch the latest tag from GitHub for the vscode-apptainer repository."
	exit 1
fi

# Check that apptainer is installed
if ! command -v apptainer &> /dev/null; then
    echo "Error: apptainer is not installed. Please install apptainer."
    exit 1
fi

# Ask where to install code-app, default is ~/.local/bin
read -p "Where do you want to install code-app? [~/.local/bin]: " VSCODE_APP_DIR
VSCODE_APP_DIR=${VSCODE_APP_DIR:-$HOME/.local/bin}
mkdir -p "$VSCODE_APP_DIR"

# Download the latest release of code-app from GitHub and install it to $VSCODE_APP_DIR
echo "Downloading code-app from $REPO_URL with tag $LATEST_TAG..."
curl -L https://raw.githubusercontent.com/$REPO_URL/$LATEST_TAG/bin/code-app -o $VSCODE_APP_DIR/code-app
chmod +x $VSCODE_APP_DIR/code-app

# Ask which directory should be used for VSCODE_APP_HOME, default is ~/vscode-home
read -p "Which directory should be used for VSCODE_APP_HOME? [~/vscode-home]: " VSCODE_APP_HOME
VSCODE_APP_HOME=${VSCODE_APP_HOME:-$HOME/vscode-home}
mkdir -p "$VSCODE_APP_HOME"

# Ask where to install the vscode apptainer image, default is ~/.local/share/vscode-apptainer
read -p "Where do you want to install the VSCode Apptainer image? [~/.local/share/vscode-apptainer]: " VSCODE_APP_IMAGE_DIR
VSCODE_APP_IMAGE_DIR=${VSCODE_APP_IMAGE_DIR:-$HOME/.local/share/vscode-apptainer}
mkdir -p "$VSCODE_APP_IMAGE_DIR"

VSCODE_APP_IMAGE=$VSCODE_APP_IMAGE_DIR/vscode-apptainer.sif

# Ask which image to use for the vscode apptainer image, default is ghcr.io/$REPO_URL:$LATEST_TAG
read -p "Which image should be used as the vscode apptainer image? [ghcr.io/$REPO_URL:$LATEST_TAG]: " VSCODE_APP_IMAGE_URL
VSCODE_APP_IMAGE_URL=${VSCODE_APP_IMAGE_URL:-ghcr.io/$REPO_URL:$LATEST_TAG}

# Check if VSCODE_APP_IMAGE already exists
if [ -f "$VSCODE_APP_IMAGE" ]; then
    read -p "The VSCode Apptainer image already exists at $VSCODE_APP_IMAGE. Do you want to overwrite it? [y/N]: " OVERWRITE
    if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
        OVERWRITE_IMAGE=true
    fi
fi

if [ ! -f "$VSCODE_APP_IMAGE" ] || [ "$OVERWRITE_IMAGE" = true ]; then
    echo "Pulling the VSCode Apptainer image from $VSCODE_APP_IMAGE_URL..."
    apptainer pull -F $VSCODE_APP_IMAGE docker://$VSCODE_APP_IMAGE_URL
else
    echo "Using existing VSCode Apptainer image at $VSCODE_APP_IMAGE."
fi

# Print export statements that should be added to the user's shell configuration file
echo "Add the following lines to your shell configuration file (e.g., ~/.bashrc or ~/.zshrc) to set up the environment variables for code-app:"
echo ""
echo "export PATH=\"$VSCODE_APP_DIR:\$PATH\""
echo "export VSCODE_APP_IMAGE=$VSCODE_APP_IMAGE"
echo "export VSCODE_APP_HOME=$VSCODE_APP_HOME"
echo ""
echo "Make sure to source your shell configuration file after adding these lines to apply the changes."