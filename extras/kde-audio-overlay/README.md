# Audio Overlay for KDE Plasma

A Game Bar–style audio panel for KDE Plasma 6 on Wayland. Press a shortcut and it
drops down over whatever you're doing, including fullscreen games, so you can:

- switch output device (speakers, headset, HDMI) and change its volume
- switch microphone and change its input level
- change or mute the volume of each app that's playing sound

It follows your KDE colour scheme and font. Close it with the same shortcut,
**Esc**, or by clicking outside the panel.

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
`~/.local/share/kde-audio-overlay/`, the launcher to `~/.local/bin/`, and an
**Audio Overlay** entry appears in the app menu.

Then add a shortcut: **System Settings → Keyboard → Shortcuts → Add New →
Application → Audio Overlay**, and assign a key. To use **Meta+G**, first clear
it from KWin's **Grid View** entry, which uses it by default.

## Settings

Edit the top of `~/.local/share/kde-audio-overlay/Overlay.qml`:

```qml
readonly property string position: "top"   // "top", "center" or "bottom"
readonly property int edgeOffset: 52       // distance from the screen edge, e.g. panel height + gap
readonly property real sizeFactor: 1.0     // 0.8 = smaller, 1.2 = bigger
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
- The overlay opens on the screen you're using and is drawn above every
  window, fullscreen games included (native Wayland and XWayland).
