# vscode-apptainer

## About this repository

This repository contains a Dockerfile and a couple of scripts that make it
possible to run VSCode inside an Apptainer image.

Motivation for this was to limit the access of GitHub Copilot and other AI agents
from accessing user's home folder or other project's folders.

The whole things works like this:

1. VSCode, git and Google Chrome (for logging in to Github Copilot) are all installed in an Apptainer image.
2. When running the image, you can tell Apptainer to mount a different folder to the location where your `/home`-folder would be.
3. For the graphical use and for access to your keyring etc. `/run/dbus` and `/run/user/$UID` are mounted into the container.
4. The project folder you want to work on will be mapped to `/project`, which will be used as the starting directory and VSCode will open that directory.

## Installation and usage

### With install.sh and with code-app

You will need [Apptainer](https://apptainer.org/) so that you can run the VSCode image.

If you have it installed, you can use the included `install.sh`-script to install the `code-app` script.

```sh
curl -L https://raw.githubusercontent.com/AaltoRSE/vscode-apptainer/main/install.sh -o install.sh
bash install.sh
```

The script will ask you where you want to install the `code-app`-script, the Apptainer image and what directory should be the VSCode home directory. At the end it will show the environment variables you should set in your `.bashrc`/`.zshrc` for continued use.

After running the installation and exporting the environment variables, you can launch VSCode in a container with

```sh
code-app DIRECTORY
```

where `DIRECTORY` is the folder you want to mount to `/project` inside the container. The editor will run in
an Apptainer instance. To stop the instance, run:

```sh
code-app -s
```

You can also mount a folder with multiple project folders into the editor with
```sh
code-app -p /my/project/folder project1
```
where `project1` would be a subfolder of your project folder.

Then you can launch new windows in VSCode for different workspaces in that folder.

### Without install.sh and code-app

If you do not want to use the install script, you can the same with the following commands:
```sh
# Path to the VSCode apptainer image
VSCODE_APP_IMAGE=$PWD/vscode-apptainer_latest.sif

# Pull the image
apptainer pull $VSCODE_APP_IMAGE docker://ghcr.io/aaltorse/vscode-apptainer:latest

# Folder for VSCode home directory
export VSCODE_APP_HOME=~/vscode-home
mkdir -p $VSCODE_APP_HOME

# Project you want to open (e.g. current directory)
export VSCODE_APP_PROJECT_DIR=$PWD

# Run VSCode in a container
apptainer exec --no-home -B /run/dbus -B /run/user/$(id -u) -B "$VSCODE_APP_HOME":$HOME -B "$VSCODE_APP_PROJECT_DIR":/project --cwd /project "$VSCODE_APP_IMAGE" code --wait .
```

### Building the Apptainer image yourself

If you do not want to use the pre-built image or you want to create your own, you can use the following commands:

1. Make certain you have Docker and Apptainer installed.
2. Clone this repository and go to the main folder.
3. Build a Docker image out of Dockerfile.
```sh
docker build -t vscode-apptainer:latest .
```
4. Create an Apptainer image from the locally built Docker image:
```sh
apptainer pull -F docker-daemon:vscode-apptainer:latest
```

# Contributing

If you encounter any bugs or issues, you can contribute by creating an issue or a pull request.

The code has been tested on a Ubuntu 24.04 system so there might some differences in other systems.

# License

All code here is licenced under MIT License. See [LICENSE](./LICENSE) for more information.