#!/bin/bash
set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# this installs a package from fedora repos
dnf5 install -y just

dnf5 clean all
systemctl enable podman.socket
