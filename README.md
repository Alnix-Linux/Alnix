# Alnix

Alnix is an Arch Linux–based distribution with the KDE Plasma desktop, built to be easy for beginners and hard to break.

It comes with a graphical installer, takes a snapshot before every system change so mistakes can be undone, and installs apps and updates through Discover. You shouldn't need a terminal for everyday use.

> **Status:** early development. The installer has barely been tested on real hardware, so try it in a virtual machine first.

![Alnix Screenshot](screenshots/alnix.jpeg)

## Features

- **Graphical installer.** The installer opens automatically when the live desktop starts. It works offline, and the "Erase disk" option sets up everything, with optional disk encryption. Windows and other operating systems are detected for dual boot.
- **Undo for mistakes.** Alnix uses the Btrfs filesystem with [Snapper](https://github.com/openSUSE/snapper). A snapshot is taken before every system update or system package change, and a permanent "Fresh Alnix install" snapshot is kept. If an update breaks something, you can boot an earlier snapshot from the boot menu and restore it with Btrfs Assistant.
- **One-click updates.** Discover shows a notification when updates are ready. Apps come from the Arch repositories and from Flathub.
- **Low maintenance.** Package mirrors are refreshed weekly, the Arch signing keys stay up to date, old cached packages are cleaned up, and SSDs are trimmed on a schedule.
- **Safe defaults.** The firewall (ufw) is on, and the root account is locked. System changes ask for your own password, and SSH is off.
- **Compressed swap in RAM (zram),** so no swap partition is needed.

## Installing Alnix

1. Download or build the ISO (see [Building](#building)).
2. Write it to a USB drive with a tool such as [Fedora Media Writer](https://github.com/FedoraQt/MediaWriter), [balenaEtcher](https://etcher.balena.io/) or `dd`.
3. Boot from the USB drive. The live desktop starts and the installer opens.
4. Follow the steps, then restart when the installer finishes.

System requirements: a 64-bit PC, at least 2 GB of RAM and 20 GB of disk space.

## Restoring an earlier snapshot

1. Restart the computer and choose **Alnix snapshots** in the boot menu.
2. Pick a snapshot from before the problem started. It boots with its own temporary changes, and nothing is saved.
3. Open **Btrfs Assistant**, go to **Snapper**, select the same snapshot and click **Restore**.
4. Restart.

## Building

The ISO can only be built on Arch Linux or an Arch-based system. You need:

- `archiso`
- `arch-install-scripts`
- `git`
- `base-devel`

Build with:

```sh
sudo ./build-iso.sh
```

The ISO is written to `out/`.

The first build also builds the Calamares installer from the [AUR](https://aur.archlinux.org/packages/calamares) into a local package repository in `repo/`, because Calamares isn't in the official Arch repositories. The packages are compiled as an unprivileged user inside a clean Arch chroot, and your own system's packages are not touched. This takes several minutes.

To rebuild Calamares, for example after it has an update:

```sh
sudo ./build-iso.sh --rebuild-repo
```

The build uses these folders:

- `work/`: temporary build files. Safe to delete.
- `repo/`: the local package repository.
- `out/`: the finished ISO.

## Project layout

| Path | Contents |
| --- | --- |
| `build-iso.sh` | Builds the ISO |
| `build-repo.sh` | Builds AUR packages into the local repository |
| `alnix/` | The [archiso](https://wiki.archlinux.org/title/Archiso) profile |
| `alnix/packages.x86_64` | Packages included in the live system, and in installed systems |
| `alnix/profiledef.sh` | ISO name, boot modes and file permissions |
| `alnix/airootfs/` | Files copied into the system as-is |
| `alnix/airootfs/etc/calamares/` | Installer configuration, branding and slideshow |
| `alnix/airootfs/usr/share/grub/themes/alnix/` | GRUB theme for installed systems, based on [Graphite](https://github.com/vinceliuice/Graphite-gtk-theme) |
| `alnix/airootfs/usr/lib/alnix-installer/` | Scripts that turn the live system into an installed system |
| `alnix/syslinux/`, `alnix/grub/`, `alnix/efiboot/` | Boot menus for BIOS and UEFI |

### How installation works

The installer copies the live system image onto the disk. The `cleanup-live` script then removes everything that belongs only to the live session: the passwordless live user, autologin, the archiso boot hooks and the installer itself. The `finalize` script turns on the firewall, sets up Snapper and takes the first snapshot.

To add software to Alnix, add it to `alnix/packages.x86_64`. Because the installer copies the live system, anything in the live system also ends up in installed systems.

## License

Alnix is licensed under the [GNU General Public License v3.0](LICENSE).

Alnix is not affiliated with or endorsed by Arch Linux.