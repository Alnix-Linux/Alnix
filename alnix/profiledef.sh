#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="alnix"
iso_label="ALNIX_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Alnix"
iso_application="Alnix Live/Installer"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="alnix"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86,arm64' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/gshadow"]="0:0:400"
  ["/home/live"]="1000:1000:750"
  ["/home/live/Desktop"]="1000:1000:755"
  ["/home/live/Desktop/alnix-install.desktop"]="1000:1000:755"
  ["/home/live/.config"]="1000:1000:755"
  ["/home/live/.config/autostart"]="1000:1000:755"
  ["/home/live/.config/autostart/alnix-install.desktop"]="1000:1000:644"
  ["/etc/sudoers.d"]="0:0:750"
  ["/etc/sudoers.d/10-live"]="0:0:440"
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/lib/alnix/xfce-theme"]="0:0:755"
  ["/usr/lib/alnix-installer/apply-choices"]="0:0:755"
  ["/usr/lib/alnix-installer/cleanup-live"]="0:0:755"
  ["/usr/lib/alnix-installer/finalize"]="0:0:755"
  ["/usr/local/bin/alnix-install"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)
