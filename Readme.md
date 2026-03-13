# MPM — Masensen Package Manager

**Version:** 1.0  
**Author:** Masensen

MPM is a simple, cross-distro system package manager designed to manage updates, cleanups, and package installations on Linux systems. It supports **Ubuntu/Debian**, **Fedora**, and **Arch Linux**, including Flatpak and Snap packages.

---

## Features

- System package updates (`apt`, `dnf`, `pacman`)
- Flatpak updates
- Snap updates
- System cleaning (cache and temporary files)
- Refresh GNOME icons and desktop entries
- Interactive file conflict resolution during installation or uninstallation
- Multi-shell support with Bash integration

---

## Installation

1. Clone or copy MPM to your system:

```bash
git clone "https://github.com/m4sensen/mpm.git" ~/Downloads/mpm
cd ~/Downloads/mpm
sudo bash install.sh
```

2. Ensure `mpm` is globally accessible:

- The installer automatically adds `mpm/bin` to your `PATH` (for Bash shells).
- You can manually check with:

```bash
echo $PATH
mpm version
```

---

## Usage

MPM provides a single global command `mpm` with the following subcommands:

| Command         | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| `mpm update`    | Run a full system update including Flatpak and Snap packages |
| `mpm uninstall` | Remove MPM and its associated scripts and desktop entries    |
| `mpm version`   | Display MPM version, author, supported systems, and features |

### Examples

```bash
# Run system updates
mpm update

# Remove MPM from your system
mpm uninstall

# Show MPM information
mpm version
```

---

## File Structure

After installation, the directory structure is:

```
/usr/local/bin/mpm          # main executable (mpm command)
└── lib/                    # helper scripts (update.sh, uninstall.sh)
└── bin/                    # optional helper executables
/usr/share/applications/mpm.desktop  # desktop entry for GUI launchers
/usr/share/icons/hicolor/scalable/apps/mpm.svg  # application icon
```

---

## Conflict Resolution

During installation or uninstallation, if a file already exists, MPM will prompt:

```
File /path/to/file already exists. [S]kip/[R]eplace/[C]ancel?
```

- **S** → Skip the file
- **R** → Replace the file
- **C** → Cancel the entire operation

This ensures safety and avoids accidental overwrites.

---

## Supported Systems

- **Ubuntu / Debian**: `apt` for package updates
- **Fedora**: `dnf` for package updates
- **Arch Linux**: `pacman` for package updates
- **Flatpak**: universal package updates
- **Snap**: universal package updates

---

## License

This project is released under [MIT License](LICENSE).

---

## Author

**Masensen** – Linux enthusiast and software automation developer

---

> ⚠️ Note: Always run `mpm` commands with appropriate permissions (sudo may be required for system updates and icon installations).

```

---

If you want, I can also **add a “Developer Guide” section** showing:

- How to add new MPM commands
- How to extend support for other Linux distributions
- How to add custom scripts inside `/usr/local/bin/mpm/lib`

This would make your README fully professional.

Do you want me to do that?
```
