#!/usr/bin/env bash
# Build the AUR packages Alnix needs (the Calamares installer) into a local
# pacman repository at repo/x86_64, which build-iso.sh feeds to mkarchiso.
# Also builds the larp package for now
#
# Packages are built as an unprivileged user inside a clean Arch Linux chroot,
# so the result does not depend on (or touch) the host system's packages.
set -euo pipefail

# The host's locale may not exist in the build chroot; C.UTF-8 always does.
export LANG=C.UTF-8 LC_ALL=C.UTF-8

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_name="alnix-local"
repo_dir="${root_dir}/repo/x86_64"
chroot_dir="${root_dir}/work/buildroot"
src_dir="${root_dir}/work/aur"

# Built in this order; later packages may depend on earlier ones.
aur_packages=(ckbcomp calamares larp)

if (( EUID != 0 )); then
    echo "This script must be run as root: sudo $0" >&2
    exit 1
fi

mkdir -p "$repo_dir" "$src_dir"

# Fetch or update the AUR build recipes.
for pkg in "${aur_packages[@]}"; do
    if [[ -d "${src_dir}/${pkg}/.git" ]]; then
        git -C "${src_dir}/${pkg}" pull --ff-only
    else
        git clone "https://aur.archlinux.org/${pkg}.git" "${src_dir}/${pkg}"
    fi
done

# Collect build and runtime dependencies from .SRCINFO, skipping the packages
# built here, and install them into the build chroot together with base-devel.
mapfile -t deps < <(
    for pkg in "${aur_packages[@]}"; do
        sed -n -E 's/^\s*(depends|makedepends|checkdepends) = ([^<>=]+).*/\2/p' "${src_dir}/${pkg}/.SRCINFO"
    done | sort -u | grep -vxF -f <(printf '%s\n' "${aur_packages[@]}")
)
mkdir -p "$chroot_dir"

# pacman (e.g. its free-space check) and arch-chroot expect the chroot to be a
# mount point, so bind-mount the directory onto itself while building.
if ! mountpoint -q "$chroot_dir"; then
    mount --bind "$chroot_dir" "$chroot_dir"
    trap 'umount "$chroot_dir"' EXIT
fi

# The profile reads the Arch mirrors from mirrorlist-arch, as on Arch-based
# hosts such as Artix. Stock Arch only has mirrorlist, so fall back to that.
mirrorlist=/etc/pacman.d/mirrorlist-arch
[[ -f "$mirrorlist" ]] || mirrorlist=/etc/pacman.d/mirrorlist
pacman_conf="${root_dir}/work/pacman-buildroot.conf"
sed "s|/etc/pacman.d/mirrorlist-arch|${mirrorlist}|" "${root_dir}/alnix/pacman.conf" > "$pacman_conf"

pacstrap -C "$pacman_conf" -c -M "$chroot_dir" --needed base-devel git "${deps[@]}"

if ! arch-chroot "$chroot_dir" id builder &>/dev/null; then
    arch-chroot "$chroot_dir" useradd -m builder
fi

for pkg in "${aur_packages[@]}"; do
    rm -rf "${chroot_dir}/home/builder/${pkg}"
    cp -r "${src_dir}/${pkg}" "${chroot_dir}/home/builder/${pkg}"
    arch-chroot "$chroot_dir" chown -R builder:builder "/home/builder/${pkg}"
    arch-chroot "$chroot_dir" su builder -c "cd ~/${pkg} && makepkg --force --cleanbuild --noconfirm"

    # Install the fresh package in the chroot so later packages can depend on it.
    built=("${chroot_dir}/home/builder/${pkg}/"*.pkg.tar.zst)
    arch-chroot "$chroot_dir" pacman -U --noconfirm "${built[@]#"${chroot_dir}"}"
    for file in "${built[@]}"; do
        cp "$file" "$repo_dir/"
        repo-add --remove "${repo_dir}/${repo_name}.db.tar.gz" "${repo_dir}/${file##*/}"
    done
done

chown -R "$(stat -c '%u:%g' "$root_dir")" "${root_dir}/repo"
echo "Local repository ready: ${repo_dir}"
