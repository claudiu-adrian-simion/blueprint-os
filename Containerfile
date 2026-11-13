FROM scratch AS ctx

# Base Image
FROM quay.io/bootc-devel/fedora-bootc-45-minimal:latest

# Packages
## Basic system usability
RUN dnf5 install clear -y --setopt=install_weak_deps=False

## Networking
RUN dnf5 install NetworkManager -y --setopt=install_weak_deps=False
RUN dnf5 install NetworkManager-wifi -y --setopt=install_weak_deps=False

## Hardware
### Wifi and bt firmware's
RUN dnf5 install tiwilink-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install realtek-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install qcom-wwan-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install nxpwireless-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install atheros-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install brcmfmac-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install mt7xxx-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install iwlwifi-mvm-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install iwlwifi-mld-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install iwlwifi-dvm-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install iwlbluetooth-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install iwlegacy-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install libertas-firmware -y --setopt=install_weak_deps=False
RUN dnf5 install atmel-firmware -y --setopt=install_weak_deps=False

### SYSTEM FILES
## Copy the contents of system_files/ to /
COPY system_files/ /

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
