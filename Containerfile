FROM scratch AS ctx

# Base Image
FROM quay.io/bootc-devel/fedora-bootc-45-minimal:latest

# Packages
#---------------------------------------------------------------------
# System crytical, do not remove.
#---------------------------------------------------------------------
RUN dnf5 install rpm-ostree -y --setopt=install_weak_deps=False
RUN dnf5 install linux-firmware -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# Basic System usability, not needed but reccomended.
#---------------------------------------------------------------------
RUN dnf5 install sudo -y --setopt=install_weak_deps=False
RUN dnf5 install clear -y --setopt=install_weak_deps=False
RUN dnf5 install shadow-utils -y --setopt=install_weak_deps=False
RUN dnf5 install polkit -y --setopt=install_weak_deps=False
RUN dnf5 install just -y --setopt=install_weak_deps=False
# Kills a runaway app before the system freezes when memory runs out
RUN dnf5 install systemd-oomd-defaults -y --setopt=install_weak_deps=False


#---------------------------------------------------------------------
# Filesystem support
#---------------------------------------------------------------------
# NVMe SSD tools (health, firmware info): for machines with an NVMe drive (lspci shows "Non-Volatile memory").
# Remove it on SATA-only or VM setups.
RUN dnf5 install nvme-cli -y --setopt=install_weak_deps=False

# Btrfs tools: keep if your root or any drive uses Btrfs (check: findmnt -no FSTYPE /).
# Remove it if you only use XFS or ext4.
RUN dnf5 install btrfs-progs -y --setopt=install_weak_deps=False

# LUKS command-line tool (luksOpen, luksAddKey, luksFormat): for anyone with an encrypted disk, USB stick
# or external drive. Remove it if you never use disk encryption.
RUN dnf5 install cryptsetup -y --setopt=install_weak_deps=False

# Automatic disk unlock at boot with a TPM chip or a Tang key server: only for people who set up
# Clevis on an encrypted (LUKS) disk. If you type your passphrase at boot, remove it.
RUN dnf5 install clevis-dracut -y --setopt=install_weak_deps=False

# Drive mounting service: file managers use it to automount USB sticks and external disks. Needed on any desktop.
RUN dnf5 install udisks2 -y --setopt=install_weak_deps=False

# exFAT tools (format and repair): for USB sticks, SD cards and drives shared with Windows or Mac.
RUN dnf5 install exfatprogs -y --setopt=install_weak_deps=False

# NTFS read/write and repair: for Windows-formatted drives or a dual-boot Windows partition.
RUN dnf5 install ntfs-3g -y --setopt=install_weak_deps=False

# Compressed swap in RAM: recommended on any desktop, since Fedora has no disk swap by default.
RUN dnf5 install zram-generator -y --setopt=install_weak_deps=False


#---------------------------------------------------------------------
# Networking
#---------------------------------------------------------------------
RUN dnf5 install NetworkManager -y --setopt=install_weak_deps=False
RUN dnf5 install NetworkManager-wifi -y --setopt=install_weak_deps=False

# WiFi firmwares: keep ONLY the line(s) for your Wi-Fi chip, comment out the rest.
# If unsure keep eveything

## Intel (most common in laptops)
# RUN dnf5 install iwlwifi-mld-firmware -y --setopt=install_weak_deps=False
# RUN dnf5 install iwlwifi-mvm-firmware -y --setopt=install_weak_deps=False
# RUN dnf5 install iwlwifi-dvm-firmware -y --setopt=install_weak_deps=False
# RUN dnf5 install iwlegacy-firmware -y --setopt=install_weak_deps=False

## Realtek (very common in budget laptops and USB adapters)
# RUN dnf5 install realtek-firmware -y --setopt=install_weak_deps=False

## MediaTek (common in newer AMD laptops and Wi-Fi 6/6E/7 cards)
RUN dnf5 install mt7xxx-firmware -y --setopt=install_weak_deps=False

## Qualcomm / Atheros (older laptops, some routers and dongles)
# RUN dnf5 install atheros-firmware -y --setopt=install_weak_deps=False

## Broadcom (older laptops, Apple hardware, Raspberry Pi)
# RUN dnf5 install brcmfmac-firmware -y --setopt=install_weak_deps=False

## NXP / Marvell (embedded boards, some Surface devices)
# RUN dnf5 install nxpwireless-firmware -y --setopt=install_weak_deps=False

## Marvell Libertas (very old USB and SDIO adapters)
# RUN dnf5 install libertas-firmware -y --setopt=install_weak_deps=False

## WiLink (Texas Instruments, embedded boards)
# RUN dnf5 install tiwilink-firmware -y --setopt=install_weak_deps=False

## Atmel (very old adapters)
# RUN dnf5 install atmel-firmware -y --setopt=install_weak_deps=False

## Firewall (Fedora's default; any machine on a network)
RUN dnf5 install firewalld -y --setopt=install_weak_deps=False

## Time sync: keeps the clock correct (needed for HTTPS and package signature checks). Any machine.
RUN dnf5 install chrony -y --setopt=install_weak_deps=False

# OpenVPN support in NetworkManager: only if you use OpenVPN
# RUN dnf5 install NetworkManager-openvpn -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# Bluetooth
#---------------------------------------------------------------------
# Actual bluetooth support: any machine with Bluetooth (headphones, mice, keyboards)
RUN dnf5 install bluez -y --setopt=install_weak_deps=False

# Intel bluetooth firmware: only for Intel Bluetooth chips (other vendors ship it with their Wi-Fi package)
RUN dnf5 install iwlbluetooth-firmware -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# CPU and GPU
#---------------------------------------------------------------------
# AMD CPU microcode
RUN dnf5 install amd-ucode-firmware -y --setopt=install_weak_deps=False

# AMD GPU firmware
RUN dnf5 install amd-gpu-firmware -y --setopt=install_weak_deps=False

# Intel GPU firmware
# RUN dnf5 install intel-gpu-firmware -y --setopt=install_weak_deps=False

# NVIDIA GPU firmware
# RUN dnf5 install nvidia-gpu-firmware -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# Graphics stack
#---------------------------------------------------------------------
# Open-source OpenGL/EGL drivers: needed on any desktop with an AMD or Intel GPU (also Nouveau for NVIDIA)
RUN dnf5 install mesa-dri-drivers -y --setopt=install_weak_deps=False

# Vulkan drivers: games, Proton and modern apps (AMD and Intel GPUs)
RUN dnf5 install mesa-vulkan-drivers -y --setopt=install_weak_deps=False

# Hardware video decode (VA-API): smooth video playback in browsers and media players
# RUN dnf5 install mesa-va-drivers -y --setopt=install_weak_deps=False

# Runs X11-only apps on a Wayland desktop: needed on any Wayland desktop
RUN dnf5 install xorg-x11-server-Xwayland -y --setopt=install_weak_deps=False

# Touchpad, mouse and keyboard handling: any desktop
RUN dnf5 install libinput -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# Firmware updates
#---------------------------------------------------------------------
# BIOS and device firmware updates (the daemon): for machines whose vendor supports fwupd
# (check: fwupdmgr get-devices)
RUN dnf5 install fwupd -y --setopt=install_weak_deps=False
# EFI helper that applies the update on the next reboot
RUN dnf5 install fwupd-efi -y --setopt=install_weak_deps=False
# On-screen progress while a UEFI firmware update installs: UEFI machines
RUN dnf5 install fwupd-plugin-uefi-capsule-data -y --setopt=install_weak_deps=False
# Local cache that shares firmware metadata between machines on the network
RUN dnf5 install passim -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# Power management
#---------------------------------------------------------------------
# Battery level and charging state: laptops (desktop PCs can skip it)
RUN dnf5 install upower -y --setopt=install_weak_deps=False

# Power profiles (Power Saver / Balanced / Performance): the tuned daemon and its standard-interface wrapper
RUN dnf5 install tuned -y --setopt=install_weak_deps=False
RUN dnf5 install tuned-ppd -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# Audio (PipeWire)
#---------------------------------------------------------------------
# Sound server, session manager and PulseAudio compatibility: any desktop with sound
RUN dnf5 install pipewire -y --setopt=install_weak_deps=False
RUN dnf5 install wireplumber -y --setopt=install_weak_deps=False
RUN dnf5 install pipewire-pulseaudio -y --setopt=install_weak_deps=False

# Routes apps that talk to ALSA directly through PipeWire
RUN dnf5 install pipewire-alsa -y --setopt=install_weak_deps=False
# Per-device profiles so speakers, headphones and microphones work correctly: most laptops
RUN dnf5 install alsa-ucm -y --setopt=install_weak_deps=False
# Firmware for SOF audio DSPs (needed for the built-in mic on many laptops)
RUN dnf5 install alsa-sof-firmware -y --setopt=install_weak_deps=False
# Realtime scheduling for PipeWire, prevents audio crackling: any desktop
RUN dnf5 install rtkit -y --setopt=install_weak_deps=False
# pw-cli, pw-top and other PipeWire debugging tools: optional, for troubleshooting
RUN dnf5 install pipewire-utils -y --setopt=install_weak_deps=False
# Webcam support through PipeWire: machines with a webcam
RUN dnf5 install pipewire-plugin-libcamera -y --setopt=install_weak_deps=False
# JACK compatibility: only for pro-audio apps
# RUN dnf5 install pipewire-jack-audio-connection-kit -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# FONTS
#---------------------------------------------------------------------

## Look-alikes for Arial, Times New Roman and Courier (documents and websites)
RUN dnf5 install liberation-sans-fonts -y --setopt=install_weak_deps=False
RUN dnf5 install liberation-serif-fonts -y --setopt=install_weak_deps=False
RUN dnf5 install liberation-mono-fonts -y --setopt=install_weak_deps=False
RUN dnf5 install dejavu-sans-fonts -y --setopt=install_weak_deps=False
RUN dnf5 install dejavu-serif-fonts -y --setopt=install_weak_deps=False
RUN dnf5 install dejavu-sans-mono-fonts -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# Desktop integration (shared by KDE, GNOME and COSMIC)
#---------------------------------------------------------------------
# App store and sandboxed apps: any desktop that installs apps from Flathub
RUN dnf5 install flatpak -y --setopt=install_weak_deps=False

# Portals: Flatpak file pickers, screen sharing and "open with" dialogs
# (also add the portal backend that matches your desktop environment)
RUN dnf5 install xdg-desktop-portal -y --setopt=install_weak_deps=False

# Saved passwords for apps (needs a keyring service from your desktop) and GPG/PIN prompts
RUN dnf5 install libsecret -y --setopt=install_weak_deps=False
RUN dnf5 install pinentry -y --setopt=install_weak_deps=False

# Creates Documents, Downloads, etc. in the home folder
RUN dnf5 install xdg-user-dirs -y --setopt=install_weak_deps=False
# xdg-open and friends: open links and files with the right app
RUN dnf5 install xdg-utils -y --setopt=install_weak_deps=False

# Location service: automatic time zone, night light, weather
RUN dnf5 install geoclue2 -y --setopt=install_weak_deps=False
# Display color profile management
RUN dnf5 install colord -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# Language and locale
#---------------------------------------------------------------------
# English locale data. For another language add glibc-langpack-<code> (for example
# glibc-langpack-ro), or use glibc-all-langpacks for every language (large)
RUN dnf5 install glibc-langpack-en -y --setopt=install_weak_deps=False

# Typing in other scripts (choose ibus OR fcitx5, not both): only if you type non-Latin scripts
# RUN dnf5 install ibus -y --setopt=install_weak_deps=False
# RUN dnf5 install fcitx5 -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# Printing and scanning
#---------------------------------------------------------------------
# Print system and its permission helper: only if you print
# RUN dnf5 install cups -y --setopt=install_weak_deps=False
# RUN dnf5 install cups-pk-helper -y --setopt=install_weak_deps=False
# Driverless scanner support: only if you scan
# RUN dnf5 install sane-airscan -y --setopt=install_weak_deps=False

#---------------------------------------------------------------------
# Laptop and hardware extras (remove what your hardware lacks)
#---------------------------------------------------------------------
# Fingerprint reader login (fprintd-pam enables it for login and sudo prompts): machines with a fingerprint reader
RUN dnf5 install fprintd -y --setopt=install_weak_deps=False
RUN dnf5 install fprintd-pam -y --setopt=install_weak_deps=False
# Thunderbolt/USB4 device authorization: machines with Thunderbolt or USB4 ports
RUN dnf5 install bolt -y --setopt=install_weak_deps=False
# Ambient light and orientation sensors: laptops and tablets with those sensors
# RUN dnf5 install iio-sensor-proxy -y --setopt=install_weak_deps=False
# Switch between two GPUs: only machines with integrated plus dedicated GPU
# RUN dnf5 install switcheroo-control -y --setopt=install_weak_deps=False

### SYSTEM FILES
## Copy the contents of system_files/ to /
COPY system_files/ /

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
