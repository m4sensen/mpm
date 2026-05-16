# MPM — Masensen Package Manager

A cross-distro Linux system updater with a clean terminal UI.

## Supported Systems

> Requires GNOME desktop environment

- Ubuntu / Debian
- Fedora
- Arch Linux

## Features

- System package updates (apt / dnf / pacman)
- Flatpak updates
- Snap updates
- Automatic cleanup of orphaned/cached packages
- GNOME icon cache refresh

## Installation

```bash
git clone https://github.com/m4sensen/mpm.git
cd mpm
sudo bash install.sh
```

## Usage

```bash
mpm update      # Run a full system update
mpm uninstall   # Remove mpm from your system
mpm version     # Show version and feature info
```

## Uninstall

```bash
mpm uninstall
```

## License

See [LICENSE](LICENSE).
