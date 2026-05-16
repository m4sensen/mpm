# MPM — Masensen Package Manager

A cross-distro Linux system updater with a clean terminal UI.

## Supported Systems

- Ubuntu / Debian / Linux Mint / Pop!_OS
- Fedora
- Arch Linux / Manjaro / EndeavourOS

## Features

- System package updates (apt / dnf / pacman)
- Flatpak updates
- Snap updates
- Automatic cleanup of orphaned/cached packages
- GNOME icon cache refresh

## Installation

```bash
git clone https://github.com/masensen/mpm.git
cd mpm
sudo bash install.sh
```

Then restart your shell or run:

```bash
source ~/.bashrc
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

Or manually:

```bash
sudo bash /path/to/mpm/install.sh  # then choose uninstall
```

## License

See [LICENSE](LICENSE).
