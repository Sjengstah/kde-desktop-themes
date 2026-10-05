# STARGATE Audio

The STARGATE audio overlay (Stargate SG-1–inspired look) for KDE Plasma 6 on Wayland, like the
Windows Game Bar audio panel. Press a shortcut and it drops down over whatever
you're doing, fullscreen games included, so you can:

- switch output device and change the master volume
- switch microphone and change its input level
- change or mute the volume of each app that's playing sound

Close it with the same shortcut, **Esc**, or by clicking outside the panel.

## Requirements

- KDE Plasma 6 on **Wayland** (the overlay uses layer-shell, which X11 doesn't have)
- PipeWire or PulseAudio (standard on Fedora and CachyOS)
- The Qt 6 QML runtime

On a normal Plasma desktop everything except possibly the QML runtime is
already installed. `install.sh` checks and tells you what's missing:

| Distro | Command |
|---|---|
| Fedora | `sudo dnf install qt6-qtdeclarative layer-shell-qt plasma-pa kf6-kirigami` |
| Arch / CachyOS | `sudo pacman -S qt6-declarative layer-shell-qt plasma-pa kirigami` |

If Fedora still can't find the runtime, `dnf provides '*/qt6/bin/qml'` shows
which package has it.

## Install

```sh
./install.sh
```

This installs for your user only (no root): the overlay goes to
`~/.local/share/stargate-audio/`, the launcher to `~/.local/bin/`, and an
**STARGATE Audio** entry appears in the app menu.

Then add a shortcut: **System Settings → Keyboard → Shortcuts → Add New →
Application → STARGATE Audio**, and assign a key. To use **Meta+G**, first clear
it from KWin's **Grid View** entry, which uses it by default.

## Settings

Edit the top of `~/.local/share/stargate-audio/Overlay.qml`:

```qml
readonly property int topPanelHeight: 34   // height of your top panel (0 if you have none)
readonly property int panelGap: 8          // space between the panel and the overlay
readonly property real sizeFactor: 0.7     // 1.0 = full size
```

The changes apply the next time you open it.

## Uninstall

```sh
./uninstall.sh
```

Then remove the shortcut in System Settings.

## Notes

- It uses Plasma's own audio module (`org.kde.plasma.private.volume`), the same
  one the volume applet uses. It's a private API, so a future Plasma release
  could change it.
- The STARGATE font is Rajdhani (SemiBold), included under the SIL Open Font License
  (`fonts/OFL.txt`).
