#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# this installs a package from fedora repos
dnf5 install -y just

# Swap to the CachyOS kernel
# https://github.com/ublue-os/bazzite/blob/main/build_files/install-kernel-akmods

## Remove stock kernel and cleanup
pushd /usr/lib/kernel/install.d
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x 05-rpmostree.install 50-dracut.install
popd

for pkg in kernel kernel{-core,-modules,-modules-core,-modules-extra,-tools-libs,-tools}; do
    rpm --erase "${pkg}" --nodeps
done

### Install CachyOS kernel
dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y install kernel-cachyos kernel-cachyos-devel-matched
dnf5 -y copr disable bieszczaders/kernel-cachyos

### Install CachyOS kernel addons
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons
dnf5 -y install cachyos-settings scx-scheds
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

dnf5 clean all
systemctl enable podman.socket
