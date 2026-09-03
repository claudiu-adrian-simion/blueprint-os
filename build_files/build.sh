#!/bin/bash
set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# this installs a package from fedora repos
dnf5 install -y just cryptsetup

### Swap to the CachyOS kernel ###
# https://github.com/ublue-os/bazzite/blob/main/build_files/install-kernel-akmods

## Stub the install.d hooks — restored at the very end of this block
pushd /usr/lib/kernel/install.d
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x 05-rpmostree.install 50-dracut.install
popd

## Remove the stock kernel
for pkg in kernel kernel{-core,-modules,-modules-core,-modules-extra,-tools-libs,-tools}; do
    rpm --erase "${pkg}" --nodeps
done
rm -rf /usr/lib/modules

## Install CachyOS kernel
dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y install kernel-cachyos kernel-cachyos-devel-matched
dnf5 -y copr disable bieszczaders/kernel-cachyos
dnf5 versionlock add kernel-cachyos kernel-cachyos-devel-matched

## Generate the initramfs — the 50-dracut.install hook is stubbed above, so
## nothing built one for this kernel automatically. --add crypt is required
## for LUKS: there's no real disk to detect during a container build, so
## dracut can't infer it — it has to be forced in explicitly.
kver=$(basename /usr/lib/modules/*)
depmod -a "$kver"

if [ -x /usr/libexec/rpm-ostree/wrapped/dracut ]; then
    dracut_bin=/usr/libexec/rpm-ostree/wrapped/dracut
else
    dracut_bin=dracut
fi

"$dracut_bin" --no-hostonly --kver "$kver" --reproducible -v --add "ostree crypt" \
    -f "/usr/lib/modules/$kver/initramfs.img"

### Install CachyOS kernel addons
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons
dnf5 -y swap zram-generator-defaults cachyos-settings
dnf5 -y install scx-scheds scx-tools scx-manager ananicy-cpp
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

## Restore the normal kernel install hooks
pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

dnf5 clean all
systemctl enable podman.socket
