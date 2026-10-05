# STARWARS Desktop — How-To

Everything that gives this KDE Plasma desktop its Star Wars–inspired look: what
each part is, where it lives, how to change it and how to undo it.

Folders below are under `payload/projects/` in this repository; `~/starwars-desktop` stands
for wherever you cloned it.

| Project | Folder | Status |
|---|---|---|
| System monitor widget | `starwars-monitor/` | On the desktop and top panel |
| Global theme (style, colours, windows, splash) | `starwars-theme/` | Applied by install.sh |
| Audio overlay (Meta+G) | `starwars-audio/` | Installed by install.sh |
| Plain audio overlay (Breeze look) | `extras/kde-audio-overlay/` | Not installed — optional |
| Control Center + Notification Center widgets | `starwars-control/` | In the top panel |

---

## 1. System monitor widget

STARWARS panel with CPU, GPU, memory, network and disks. Works on the desktop and in panels.

- **Settings:** right-click the widget → Configure (hardware, sections, background, footer text).
- **After editing the code:**
  ```sh
  kpackagetool6 -t Plasma/Applet -u ~/starwars-desktop/payload/projects/starwars-monitor/package
  systemctl --user restart plasma-plasmashell
  ```
- **Shareable file:** `starwars-monitor/starwars-monitor.plasmoid`. Rebuild it from `starwars-monitor/package`:
  `bsdtar --format zip -cf ../starwars-monitor.plasmoid metadata.json contents`
- **Remove:** `kpackagetool6 -t Plasma/Applet -r org.sjengstah.starwarsmonitor`

## 2. Global theme

Plasma Style, colour scheme, window decoration, wallpaper and boot splash, all named **STARWARS**.
The Plasma Style and window decoration are based on *Carl* by jomada (credit kept in the metadata).

- **Reinstall after changes:** `~/starwars-desktop/payload/projects/starwars-theme/install.sh`
- **Switch:** System Settings → Colors & Themes → Global Theme → STARWARS (or back to Carl).

### STARWARS Live wallpaper

`payload/projects/starwars-wallpaper/` is a wallpaper plugin (`org.sjengstah.starwarswallpaper`) that draws
the STARWARS wallpaper in QML, so it is sharp at any resolution, with live readouts next to the three
side blocks:

| Block | Shows |
|---|---|
| NAV | Today's destination, a different planet each day |
| MAY 4 | Days until May the 4th |
| GST | Galactic standard time: years since 1977 and day of the year |

Everything is worked out locally from the date; nothing is fetched. The static picture version (`starwars-theme/wallpapers/STARWARS`) is still there for
the lock screen or if you prefer it.

- **Settings:** right-click the desktop → Configure Desktop and Wallpaper → STARWARS Live:
  top and bottom panel height (so the labels stay clear of your panels; 0 = no panel) and
  the live data on/off switch.
- **After editing the code:**
  ```sh
  kpackagetool6 -t Plasma/Wallpaper -u ~/starwars-desktop/payload/projects/starwars-wallpaper/package
  systemctl --user restart plasma-plasmashell
  ```
- **Remove:** pick another wallpaper type, then `kpackagetool6 -t Plasma/Wallpaper -r org.sjengstah.starwarswallpaper`

### Panel transparency

```sh
panel-opacity        # show the current value
panel-opacity 60     # 10–100
```

- It restarts the Plasma shell, so the panels flicker briefly.
- Only panels set to **Translucent** follow it. **Adaptive** panels turn solid whenever a
  window is maximized. Change per panel: right-click → Show Panel Configuration → Opacity.
- Works with the STARWARS and Carl-translucent Plasma Styles.

## 3. Making every app follow the theme

| Apps | How they get the STARWARS look |
|---|---|
| KDE / Qt 6 | Automatically |
| GTK 3 (Firefox, Lutris, Meld, OnlyOffice…) | Automatically: KDE converts the colour scheme for Breeze-GTK |
| GTK 4 / libadwaita (Zenity…) | The **STARWARS block** in `~/.config/gtk-4.0/gtk.css` (see below) |
| Qt 5 (VLC) | Needs `sudo pacman -S plasma5-integration breeze5` |
| Flatpak (Chrome) | Read access to the theme files (see below), then in Chrome: Settings → Appearance → GTK |
| Electron (Discord, Steam) | Not possible through the system; only with mods (Vencord / Millennium) |

### The GTK 4 block — important

libadwaita apps ignore themes and only read `~/.config/gtk-4.0/gtk.css`. install.sh adds a
block of STARWARS colours to it:

```css
/* STARWARS-BEGIN */
...
/* STARWARS-END */
```

- This block is **fixed**: it does not change when you switch colour scheme.
  **If you move away from STARWARS, delete everything from `STARWARS-BEGIN` to `STARWARS-END`.**
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
- **Position and size:** top of `~/starwars-desktop/payload/projects/starwars-audio/Overlay.qml`
  (`topPanelHeight`, `panelGap`, `sizeFactor`), then copy it over:
  `cp payload/projects/starwars-audio/Overlay.qml ~/.local/share/starwars-audio/`
- **Shortcut:** System Settings → Keyboard → Shortcuts → STARWARS Audio. (KWin's *Grid View*
  used Meta+G before; that binding was cleared.)
- **Standalone:** `starwars-audio/` (STARWARS) or `extras/kde-audio-overlay/` (plain KDE look)
  each install on their own with `./install.sh`; see each README.
- **Remove:** `~/starwars-desktop/payload/projects/starwars-audio/uninstall.sh`, then remove the shortcut.

## 5. Control Center and Notification Center

Two separate widgets, each with its own hotkey.

**STARWARS Control Center** (panel button "CONTROL"; gold dot = caffeine on, red dot = Do Not Disturb):
- Tiles: Wi-Fi, Bluetooth (click to toggle, **›** for the network/device list), Caffeine
  (blocks sleep and screen lock), Do Not Disturb, Night Light, Home folder
- Power plan: Power Saver / Balanced / Performance (power-profiles-daemon)
- Output and microphone volume with mute
- Quick actions: Settings, Screenshot, Lock, Power menu

**STARWARS Notification Center** (panel button "ALERTS" with a count; flashes on new
notifications, turns red and reads "DND" in STARWARS Do Not Disturb):
- History with app icon, time, text and action buttons; click a card to open it, × to dismiss
- **STARWARS popups** replace KDE's notification popups (top right, under the panel, with a
  countdown bar; hover to pause; critical ones stay until dismissed)
- **STARWARS Do Not Disturb** (on/off, 1 hour, 4 hours): no popups and no notification sounds.
  Also on the Control Center's Do Not Disturb tile — both share `~/.config/starwars-desktop.conf`.
- Clear All, notification settings

**How the STARWARS popups work (important):** KDE's notification applet always draws its own
popups and can't be switched off, so the widget keeps **KDE's Do Not Disturb permanently on**
(renewed a year ahead) and turns off KDE's critical-popups-during-DND. KDE's DND also mutes
the notification sound stream; the widget unmutes it and plays each notification's sound itself.
- The crossed-out bell in the system tray is expected — hide it: System Tray → Configure →
  Entries → Notifications → Always hidden. **Don't disable that entry**: it runs KDE's
  notification service, and without it no notifications arrive at all.
- Don't use KDE's own Do Not Disturb toggle; use the STARWARS one.
- **To give KDE its popups back:** right-click the Notification Center → Configure → untick
  "Replace KDE's notification popups". That switches KDE's DND off and restores its settings.
- Popup distance from the top is in the same settings page (default 42 px = 34 px panel + 8).

**Setup:**
1. Right-click a panel → Add or Manage Widgets → search **STARWARS** → drag both in.
2. Hotkeys: right-click each widget → Configure → **Keyboard Shortcuts**.

**After editing the code** (shared STARWARS parts live in `starwars-control/shared/`):
```sh
cd ~/starwars-desktop/payload/projects/starwars-control && ./build.sh install
systemctl --user restart plasma-plasmashell
```
The `.plasmoid` files in that folder are ready to share.

## Palette

| Name | Hex | Used for |
|---|---|---|
| Orange | `#FFE81F` | Main accent, CPU, output |
| Gold | `#FF9F1C` | Values, highlights |
| Tan | `#EAF2FF` | Text |
| Peach | `#FF6B4A` | Network, apps |
| Violet | `#1F3A93` | GPU |
| Lilac | `#4FC3F7` | Memory, input |
| Blue | `#2E6DB4` | Storage |
| Sky | `#CDEBFF` | Links, downloads |
| Red | `#E0242B` | Alerts, close, mute |

Font: **Share Tech** (SIL Open Font License), installed in `~/.local/share/fonts/`.
