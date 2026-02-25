FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install wget and GPG for repository setup
RUN apt-get update && \
  apt-get dist-upgrade -y && \
  apt-get install -y --no-install-recommends curl ca-certificates wget gpg && \
  rm -rf /var/lib/apt/lists/*

# Install Microsoft's packaging key
RUN apt-get update && \
  apt-get install -y wget gpg && \
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
  install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg && \
  rm -f microsoft.gpg && \
  rm -rf /var/lib/apt/lists/*

# Install VSCode from repo
COPY vscode.sources /etc/apt/sources.list.d/vscode.sources

RUN apt-get update && \
  apt-get install -y code && \
  rm -rf /var/lib/apt/lists/*

# Add locales
RUN apt-get update && \
  apt-get install -y \
  gnome-keyring \
  locales && \
  rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_GB.UTF-8/en_GB.UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# fi_FI.UTF-8/fi_FI.UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# fi_FI ISO-8859-1/fi_FI ISO-8859-1/' /etc/locale.gen && \
    dpkg-reconfigure locales && \
    update-locale LANG=en_US.UTF-8

# Add Google Chrome for logging into Github Copilot
RUN apt-get update && \
  cd /tmp && \
  wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  apt-get install -y ./google-chrome-stable_current_amd64.deb && \
  rm ./google-chrome-stable_current_amd64.deb && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /project
