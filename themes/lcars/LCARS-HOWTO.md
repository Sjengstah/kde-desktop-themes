# LCARS Desktop — How-To

Everything that makes this KDE Plasma desktop look like Star Trek LCARS: what
each part is, where it lives, how to change it and how to undo it.

Folders below are under `payload/projects/` in this repository; `~/lcars-desktop` stands
for wherever you cloned it.

| Project | Folder | Status |
|---|---|---|
| System monitor widget | `lcars-monitor/` | On the desktop and top panel |
| Global theme (style, colours, windows, splash) | `lcars-theme/` | Applied by install.sh |
| Audio overlay (Meta+G) | `lcars-audio/` | Installed by install.sh |
| Plain audio overlay (Breeze look) | `extras/kde-audio-overlay/` | Not installed — optional |
| Control Center + Notification Center widgets | `lcars-control/` | In the top panel |

---

## 1. System monitor widget

LCARS panel with CPU, GPU, memory, network and disks. Works on the desktop and in panels.

- **Settings:** right-click the widget → Configure (hardware, sections, background, footer text).
- **After editing the code:**
  ```sh
  kpackagetool6 -t Plasma/Applet -u ~/lcars-desktop/payload/projects/lcars-monitor/package
  systemctl --user restart plasma-plasmashell
  ```
- **Shareable file:** `lcars-monitor/lcars-monitor.plasmoid`. Rebuild it from `lcars-monitor/package`:
  `bsdtar --format zip -cf ../lcars-monitor.plasmoid metadata.json contents`
- **Remove:** `kpackagetool6 -t Plasma/Applet -r org.sjengstah.lcarsmonitor`

## 2. Global theme

Plasma Style, colour scheme, window decoration, wallpaper and boot splash, all named **LCARS**.
The Plasma Style and window decoration are based on *Carl* by jomada (credit kept in the metadata).

- **Reinstall after changes:** `~/lcars-desktop/payload/projects/lcars-theme/install.sh`
- **Switch:** System Settings → Colors & Themes → Global Theme → LCARS (or back to Carl).

### Panel transparency

```sh
panel-opacity        # show the current value
panel-opacity 60     # 10–100
```

- It restarts the Plasma shell, so the panels flicker briefly.
- Only panels set to **Translucent** follow it. **Adaptive** panels turn solid whenever a
  window is maximized. Change per panel: right-click → Show Panel Configuration → Opacity.
- Works with the LCARS and Carl-translucent Plasma Styles.

## 3. Making every app follow the theme

| Apps | How they get the LCARS look |
|---|---|
| KDE / Qt 6 | Automatically |
| GTK 3 (Firefox, Lutris, Meld, OnlyOffice…) | Automatically: KDE converts the colour scheme for Breeze-GTK |
| GTK 4 / libadwaita (Zenity…) | The **LCARS block** in `~/.config/gtk-4.0/gtk.css` (see below) |
| Qt 5 (VLC) | Needs `sudo pacman -S plasma5-integration breeze5` |
| Flatpak (Chrome) | Read access to the theme files (see below), then in Chrome: Settings → Appearance → GTK |
| Electron (Discord, Steam) | Not possible through the system; only with mods (Vencord / Millennium) |

### The GTK 4 block — important

libadwaita apps ignore themes and only read `~/.config/gtk-4.0/gtk.css`. install.sh adds a
block of LCARS colours to it:

```css
/* LCARS-BEGIN */
...
/* LCARS-END */
```

- This block is **fixed**: it does not change when you switch colour scheme.
  **If you move away from LCARS, delete everything from `LCARS-BEGIN` to `LCARS-END`.**
- install.sh backs up the old file to `~/.config/desktop-themes-backup-<time>/`.
- Open GTK 4 apps need a restart to pick up changes.

### Flatpak access

All Flatpak apps may read (not write) your GTK and KDE colour files, icons and fonts:

```sh
flatpak override --user --show     # see what's granted
flatpak override --user --reset    # undo
```

## 4. Audio overlay (Meta+G)

Game Bar–style panel for output, microphone and per-app volume, drawn above everything,
fullscreen games included.

- **Open/close:** Meta+G, Esc, or click outside it.
- **Position and size:** top of `~/lcars-desktop/payload/projects/lcars-audio/Overlay.qml`
  (`topPanelHeight`, `panelGap`, `sizeFactor`), then copy it over:
  `cp payload/projects/lcars-audio/Overlay.qml ~/.local/share/lcars-audio/`
- **Shortcut:** System Settings → Keyboard → Shortcuts → LCARS Audio. (KWin's *Grid View*
  used Meta+G before; that binding was cleared.)
- **Standalone:** `lcars-audio/` (LCARS) or `extras/kde-audio-overlay/` (plain KDE look)
  each install on their own with `./install.sh`; see each README.
- **Remove:** `~/lcars-desktop/payload/projects/lcars-audio/uninstall.sh`, then remove the shortcut.

## 5. Control Center and Notification Center

Two separate widgets, each with its own hotkey.

**LCARS Control Center** (panel button "CONTROL"; gold dot = caffeine on, red dot = Do Not Disturb):
- Tiles: Wi-Fi, Bluetooth (click to toggle, **›** for the network/device list), Caffeine
  (blocks sleep and screen lock), Do Not Disturb, Night Light, Home folder
- Power plan: Power Saver / Balanced / Performance (power-profiles-daemon)
- Output and microphone volume with mute
- Quick actions: Settings, Screenshot, Lock, Power menu

**LCARS Notification Center** (panel button "ALERTS" with a count; flashes on new
notifications, turns red and reads "DND" in LCARS Do Not Disturb):
- History with app icon, time, text and action buttons; click a card to open it, × to dismiss
- **LCARS popups** replace KDE's notification popups (top right, under the panel, with a
  countdown bar; hover to pause; critical ones stay until dismissed)
- **LCARS Do Not Disturb** (on/off, 1 hour, 4 hours): no popups and no notification sounds.
  Also on the Control Center's Do Not Disturb tile — both share `~/.config/lcars-desktop.conf`.
- Clear All, notification settings

**How the LCARS popups work (important):** KDE's notification applet always draws its own
popups and can't be switched off, so the widget keeps **KDE's Do Not Disturb permanently on**
(renewed a year ahead) and turns off KDE's critical-popups-during-DND. KDE's DND also mutes
the notification sound stream; the widget unmutes it and plays each notification's sound itself.
- The crossed-out bell in the system tray is expected — hide it: System Tray → Configure →
  Entries → Notifications → Always hidden. **Don't disable that entry**: it runs KDE's
  notification service, and without it no notifications arrive at all.
- Don't use KDE's own Do Not Disturb toggle; use the LCARS one.
- **To give KDE its popups back:** right-click the Notification Center → Configure → untick
  "Replace KDE's notification popups". That switches KDE's DND off and restores its settings.
- Popup distance from the top is in the same settings page (default 42 px = 34 px panel + 8).

**Setup:**
1. Right-click a panel → Add or Manage Widgets → search **LCARS** → drag both in.
2. Hotkeys: right-click each widget → Configure → **Keyboard Shortcuts**.

**After editing the code** (shared LCARS parts live in `lcars-control/shared/`):
```sh
cd ~/lcars-desktop/payload/projects/lcars-control && ./build.sh install
systemctl --user restart plasma-plasmashell
```
The `.plasmoid` files in that folder are ready to share.

## Palette

| Name | Hex | Used for |
|---|---|---|
| Orange | `#FF9900` | Main accent, CPU, output |
| Gold | `#FFCC66` | Values, highlights |
| Tan | `#FFCC99` | Text |
| Peach | `#FF9966` | Network, apps |
| Violet | `#CC99CC` | GPU |
| Lilac | `#9999FF` | Memory, input |
| Blue | `#6699CC` | Storage |
| Sky | `#99CCFF` | Links, downloads |
| Red | `#CC6666` | Alerts, close, mute |

Font: **Antonio** (SIL Open Font License), installed in `~/.local/share/fonts/`.
