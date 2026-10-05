# MVV Desktop — How-To

Everything that gives this KDE Plasma desktop its MVV Maastricht–inspired look: what
each part is, where it lives, how to change it and how to undo it.

Folders below are under `payload/projects/` in this repository; `~/mvv-desktop` stands
for wherever you cloned it.

| Project | Folder | Status |
|---|---|---|
| System monitor widget | `mvv-monitor/` | On the desktop and top panel |
| Global theme (style, colours, windows, splash) | `mvv-theme/` | Applied by install.sh |
| Audio overlay (Meta+G) | `mvv-audio/` | Installed by install.sh |
| Plain audio overlay (Breeze look) | `extras/kde-audio-overlay/` | Not installed — optional |
| Control Center + Notification Center widgets | `mvv-control/` | In the top panel |

---

## 1. System monitor widget

MVV panel with CPU, GPU, memory, network and disks. Works on the desktop and in panels.

- **Settings:** right-click the widget → Configure (hardware, sections, background, footer text).
- **After editing the code:**
  ```sh
  kpackagetool6 -t Plasma/Applet -u ~/mvv-desktop/payload/projects/mvv-monitor/package
  systemctl --user restart plasma-plasmashell
  ```
- **Shareable file:** `mvv-monitor/mvv-monitor.plasmoid`. Rebuild it from `mvv-monitor/package`:
  `bsdtar --format zip -cf ../mvv-monitor.plasmoid metadata.json contents`
- **Remove:** `kpackagetool6 -t Plasma/Applet -r org.sjengstah.mvvmonitor`

## 2. Global theme

Plasma Style, colour scheme, window decoration, wallpaper and boot splash, all named **MVV**.
The Plasma Style and window decoration are based on *Carl* by jomada (credit kept in the metadata).

- **Reinstall after changes:** `~/mvv-desktop/payload/projects/mvv-theme/install.sh`
- **Switch:** System Settings → Colors & Themes → Global Theme → MVV (or back to Carl).

### MVV Live wallpaper

`payload/projects/mvv-wallpaper/` is a wallpaper plugin (`org.sjengstah.mvvwallpaper`) that draws
the MVV wallpaper in QML, so it is sharp at any resolution, with live readouts next to the three
side blocks:

| Block | Shows |
|---|---|
| NEXT | Next match and a countdown to kick-off; green **LIVE NOW** during the match |
| LAST | Last result |
| TABLE | MVV's Eerste Divisie position, or the leader (the free API only gives the top 5) |

Data comes from TheSportsDB's free API (public test key, no account), refreshed every 30 minutes; offline it keeps the last data and retries every 5 minutes. The static picture version (`mvv-theme/wallpapers/MVV`) is still there for
the lock screen or if you prefer it.

- **Settings:** right-click the desktop → Configure Desktop and Wallpaper → MVV Live:
  top and bottom panel height (so the labels stay clear of your panels; 0 = no panel) and
  the live data on/off switch.
- **After editing the code:**
  ```sh
  kpackagetool6 -t Plasma/Wallpaper -u ~/mvv-desktop/payload/projects/mvv-wallpaper/package
  systemctl --user restart plasma-plasmashell
  ```
- **Remove:** pick another wallpaper type, then `kpackagetool6 -t Plasma/Wallpaper -r org.sjengstah.mvvwallpaper`

### Panel transparency

```sh
panel-opacity        # show the current value
panel-opacity 60     # 10–100
```

- It restarts the Plasma shell, so the panels flicker briefly.
- Only panels set to **Translucent** follow it. **Adaptive** panels turn solid whenever a
  window is maximized. Change per panel: right-click → Show Panel Configuration → Opacity.
- Works with the MVV and Carl-translucent Plasma Styles.

## 3. Making every app follow the theme

| Apps | How they get the MVV look |
|---|---|
| KDE / Qt 6 | Automatically |
| GTK 3 (Firefox, Lutris, Meld, OnlyOffice…) | Automatically: KDE converts the colour scheme for Breeze-GTK |
| GTK 4 / libadwaita (Zenity…) | The **MVV block** in `~/.config/gtk-4.0/gtk.css` (see below) |
| Qt 5 (VLC) | Needs `sudo pacman -S plasma5-integration breeze5` |
| Flatpak (Chrome) | Read access to the theme files (see below), then in Chrome: Settings → Appearance → GTK |
| Electron (Discord, Steam) | Not possible through the system; only with mods (Vencord / Millennium) |

### The GTK 4 block — important

libadwaita apps ignore themes and only read `~/.config/gtk-4.0/gtk.css`. install.sh adds a
block of MVV colours to it:

```css
/* MVV-BEGIN */
...
/* MVV-END */
```

- This block is **fixed**: it does not change when you switch colour scheme.
  **If you move away from MVV, delete everything from `MVV-BEGIN` to `MVV-END`.**
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
- **Position and size:** top of `~/mvv-desktop/payload/projects/mvv-audio/Overlay.qml`
  (`topPanelHeight`, `panelGap`, `sizeFactor`), then copy it over:
  `cp payload/projects/mvv-audio/Overlay.qml ~/.local/share/mvv-audio/`
- **Shortcut:** System Settings → Keyboard → Shortcuts → MVV Audio. (KWin's *Grid View*
  used Meta+G before; that binding was cleared.)
- **Standalone:** `mvv-audio/` (MVV) or `extras/kde-audio-overlay/` (plain KDE look)
  each install on their own with `./install.sh`; see each README.
- **Remove:** `~/mvv-desktop/payload/projects/mvv-audio/uninstall.sh`, then remove the shortcut.

## 5. Control Center and Notification Center

Two separate widgets, each with its own hotkey.

**MVV Control Center** (panel button "CONTROL"; gold dot = caffeine on, red dot = Do Not Disturb):
- Tiles: Wi-Fi, Bluetooth (click to toggle, **›** for the network/device list), Caffeine
  (blocks sleep and screen lock), Do Not Disturb, Night Light, Home folder
- Power plan: Power Saver / Balanced / Performance (power-profiles-daemon)
- Output and microphone volume with mute
- Quick actions: Settings, Screenshot, Lock, Power menu

**MVV Notification Center** (panel button "ALERTS" with a count; flashes on new
notifications, turns red and reads "DND" in MVV Do Not Disturb):
- History with app icon, time, text and action buttons; click a card to open it, × to dismiss
- **MVV popups** replace KDE's notification popups (top right, under the panel, with a
  countdown bar; hover to pause; critical ones stay until dismissed)
- **MVV Do Not Disturb** (on/off, 1 hour, 4 hours): no popups and no notification sounds.
  Also on the Control Center's Do Not Disturb tile — both share `~/.config/mvv-desktop.conf`.
- Clear All, notification settings

**How the MVV popups work (important):** KDE's notification applet always draws its own
popups and can't be switched off, so the widget keeps **KDE's Do Not Disturb permanently on**
(renewed a year ahead) and turns off KDE's critical-popups-during-DND. KDE's DND also mutes
the notification sound stream; the widget unmutes it and plays each notification's sound itself.
- The crossed-out bell in the system tray is expected — hide it: System Tray → Configure →
  Entries → Notifications → Always hidden. **Don't disable that entry**: it runs KDE's
  notification service, and without it no notifications arrive at all.
- Don't use KDE's own Do Not Disturb toggle; use the MVV one.
- **To give KDE its popups back:** right-click the Notification Center → Configure → untick
  "Replace KDE's notification popups". That switches KDE's DND off and restores its settings.
- Popup distance from the top is in the same settings page (default 42 px = 34 px panel + 8).

**Setup:**
1. Right-click a panel → Add or Manage Widgets → search **MVV** → drag both in.
2. Hotkeys: right-click each widget → Configure → **Keyboard Shortcuts**.

**After editing the code** (shared MVV parts live in `mvv-control/shared/`):
```sh
cd ~/mvv-desktop/payload/projects/mvv-control && ./build.sh install
systemctl --user restart plasma-plasmashell
```
The `.plasmoid` files in that folder are ready to share.

## Palette

| Name | Hex | Used for |
|---|---|---|
| Orange | `#D2001F` | Main accent, CPU, output |
| Gold | `#FFD200` | Values, highlights |
| Tan | `#FFF6F0` | Text |
| Peach | `#F28C8C` | Network, apps |
| Violet | `#7A1020` | GPU |
| Lilac | `#E8B4B8` | Memory, input |
| Blue | `#9A6A6E` | Storage |
| Sky | `#F6DADB` | Links, downloads |
| Red | `#A00018` | Alerts, close, mute |

Font: **Archivo Narrow** (SIL Open Font License), installed in `~/.local/share/fonts/`.
