#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y just

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

### Swap to the CachyOS kernel
setsebool -P domain_kernel_load_modules on

curl -Lo /etc/yum.repos.d/bieszczaders-kernel-cachyos-fedora-$(rpm -E %fedora).repo \
    https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-$(rpm -E %fedora)/bieszczaders-kernel-cachyos-fedora-$(rpm -E %fedora).repo

rpm-ostree override remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra \
    --install kernel-cachyos --install scx-scheds --install scx-tools

#### Example for enabling a System Unit File

systemctl enable podman.socket
