# KDE Desktop Themes

> **Unofficial fan themes.** These themes are only *inspired by* the franchises, clubs and teams
> they are named after. They use colours and a general look only, include no crests, logos,
> show or film artwork or other copyrighted material from the rights holders, and are not
> affiliated with or endorsed by any of them. All names are trademarks of their owners; see
> [Credits and licences](#credits-and-licences) for the full list.

Eight unofficial, fan-made desktop themes for **KDE Plasma 6**, in one pack, with one installer and one
command to switch between them. Each theme changes the whole desktop at once: Plasma Style,
colours, window frame, boot splash, a system monitor widget, a control center, a notification
center with themed popups, a Meta+G audio overlay, a live wallpaper, a fastfetch greeting
and the GTK 4 colours. Your panels and your icon theme stay as they are.

| Theme | Look | Live wallpaper shows | Font |
|---|---|---|---|
| `lcars` | Star Trek LCARS–inspired: orange, lilac and blue rounded pills on black | (picture wallpaper) | Antonio |
| `rbr` | F1 Red Bull Racing–inspired: matte navy, red and yellow, angular pit-wall graphics | next session, last podium, standings (Jolpica F1) | Barlow Condensed |
| `oranje` | Dutch national team–inspired: orange, white and flag blue on dark navy | next match, last result, tournament countdown (TheSportsDB) | Oswald |
| `feyenoord` | Feyenoord-inspired: club red, white and black, De Kuip match night | next match, last result, Eredivisie position (TheSportsDB) | Teko |
| `mvv` | MVV Maastricht–inspired: red and white, De Geusselt match night | next match, last result, Eerste Divisie table (TheSportsDB) | Archivo Narrow |
| `maastricht` | Maastricht city–inspired: marl-stone gold, Maas blue and brick on slate | weather, sunrise/sunset, carnival countdown (Open-Meteo) | Fjalla One |
| `starwars` | Star Wars–inspired cockpit: crawl yellow, saber blue and red, star field | destination of the day, May the 4th countdown, galactic time (offline) | Share Tech |
| `stargate` | Stargate-inspired gate room: chevron orange and event-horizon blue | gate address of the day, iris status, teams offworld (offline) | Rajdhani |

<sub>Screenshots below: one 1920×1080 screen of a real desktop. Click a theme for all six shots
(desktop, system monitor, control center, terminal with popups, notification center, audio overlay).</sub>

| | |
|---|---|
| **LCARS** ![LCARS](docs/screenshots/lcars/1-desktop.jpg) | **RBR** ![RBR](docs/screenshots/rbr/1-desktop.jpg) |
| **ORANJE** ![ORANJE](docs/screenshots/oranje/1-desktop.jpg) | **FEYENOORD** ![FEYENOORD](docs/screenshots/feyenoord/1-desktop.jpg) |
| **MVV** ![MVV](docs/screenshots/mvv/1-desktop.jpg) | **MAASTRICHT** ![MAASTRICHT](docs/screenshots/maastricht/1-desktop.jpg) |
| **STARWARS** ![STARWARS](docs/screenshots/starwars/1-desktop.jpg) | **STARGATE** ![STARGATE](docs/screenshots/stargate/1-desktop.jpg) |

All screenshots per theme: [docs/SCREENSHOTS.md](docs/SCREENSHOTS.md)

---

## ⚠️ Read this first

**This project is 90+% vibe coded.** Most of the code was written by an AI
(Claude) while I described what I wanted, tested it and asked for changes. I am
not a QML or Plasma developer. It works on my machine, and that is the only
promise I can make.

**Use it at your own risk.** The installer changes KDE settings and binds Meta+G;
`desktop-theme setup` replaces the panels on your primary screen, and the themed
notification popups keep KDE's own Do Not Disturb switched on so they can take over.
Read the code before you run it, at least `install.sh` and `bin/desktop-theme`, and try
`./install.sh --dry-run` first.

**No support.** I won't answer questions, fix bugs on request or help get it
running on your setup. Issues and pull requests may sit unanswered. You are
responsible for keeping it updated, maintained and secure on your own system.
Feel free to fork it.

---

## Requirements

**No sudo needed.** The installer never asks for your password: everything goes into your
home folder (`~/.local/share`, `~/.local/bin`, `~/.config`). It only *checks* for the packages
below and tells you which are missing.

- KDE Plasma 6 in a **Wayland** session (the audio overlay and the popups need Wayland)
- Made and tested on **CachyOS / Arch**. Fedora package names are a best guess.

| What | Arch / CachyOS | Fedora | Needed for |
|---|---|---|---|
| Qt 6 QML runtime | `qt6-declarative` | `qt6-qtdeclarative` | Everything |
| Kirigami, KItemModels | `kirigami` `kitemmodels` | `kf6-kirigami` `kf6-kitemmodels` | All widgets |
| Layer shell | `layer-shell-qt` | `layer-shell-qt` | Meta+G audio overlay, themed popups |
| Plasma audio | `plasma-pa` | `plasma-pa` | Audio overlay, volume sliders |
| Network | `plasma-nm` | `plasma-nm` | Control Center Wi-Fi |
| Bluetooth | `bluez-qt` `bluedevil` | `kf6-bluez-qt` `bluedevil` | Control Center Bluetooth |
| Power | `powerdevil` `power-profiles-daemon` (or `tuned-ppd`) | `powerdevil` `power-profiles-daemon` | Power plan, caffeine, Night Light |
| Sensors | `libksysguard` `ksystemstats` | `libksysguard` `ksystemstats` | System Monitor, hardware detection |
| bsdtar | `libarchive` | `bsdtar` | Building the Control/Notification widgets |
| Python 3 | `python` | `python3` | Installer and `desktop-theme` |
| fastfetch | `fastfetch` | `fastfetch` | Terminal greeting (optional) |
| notify-send | `libnotify` | `libnotify` | `<theme>-test` commands (optional) |

```sh
sudo pacman -S --needed qt6-declarative kirigami kitemmodels layer-shell-qt plasma-pa plasma-nm \
  bluez-qt bluedevil powerdevil power-profiles-daemon libksysguard ksystemstats libarchive python fastfetch libnotify
```

## Install

```sh
git clone https://github.com/Sjengstah/kde-desktop-themes.git
cd kde-desktop-themes
less install.sh               # read it
./install.sh --dry-run        # see what it would do
./install.sh                  # all themes; asks which one to set up on your panels
```

Other ways:

```sh
./install.sh lcars starwars           # only these themes
./install.sh --setup oranje           # install, then build the ORANJE panels right away
./install.sh --yes                    # no questions, installs all, sets up nothing
```

The installer backs up your settings to `~/.config/desktop-themes-backup-<time>/`, puts a copy
of the themes in `~/.local/share/desktop-themes/` (so you can delete the clone afterwards) and
installs the `desktop-theme` command in `~/.local/bin`. Then:

1. **Log out and back in once** so Meta+G and the widget hotkeys work.
2. Hide the crossed-out bell in the system tray (System Tray → Configure → Entries →
   Notifications → Always hidden). **Don't disable it**: it runs KDE's notification service.

## Using it

```sh
desktop-theme list                  # all themes (* active, - not installed)
desktop-theme setup lcars           # first time: REPLACE the primary screen's panels with LCARS panels + widgets
desktop-theme starwars              # switch everything to STARWARS
desktop-theme status                # which theme is active
desktop-theme install all           # install or update themes (also: install mvv)
desktop-theme remove feyenoord      # remove a theme you don't use
```

- **First time:** `desktop-theme setup <theme>` builds a top and bottom panel on your primary
  screen with that theme's widgets (System Monitor, Control Center, Notification Center,
  Audio). If you'd rather keep your own panels, skip it and add the widgets yourself:
  right-click a panel → Add or Manage Widgets → search for the theme name.
- **Switching:** `desktop-theme <theme>` swaps the global theme, every theme widget on every
  panel and desktop (same widget, new look: settings and hotkeys stay), the wallpaper, the
  Meta+G overlay, fastfetch and the GTK 4 colours. Plasma restarts for a moment.
- **System Settings:** every theme also shows up in *Colors & Themes → Global Theme*. Picking
  one there switches the widgets, wallpaper and fastfetch too (a small systemd user unit,
  `desktop-theme-sync.path`, watches for it).
- **Icons:** never changed. The themes use whatever icon theme you've selected.
- **Wallpaper:** a theme with a live wallpaper gets it on every desktop. Pick your own
  wallpaper while a theme is active and `desktop-theme` remembers it for that theme.
- **Per theme:** `<theme>-test` sends three themed test notifications, `<theme>-fetch` shows
  the theme's fastfetch. Each theme's full guide is `themes/<theme>/<THEME>-HOWTO.md`.

## Uninstall

1. Pick another Global Theme in System Settings (e.g. Breeze) and take the theme widgets off
   your panels.
2. Run `./uninstall.sh` from the clone (deleted it? clone the repo again).

It removes the themes, widgets, overlays, commands and the sync unit, and the GTK 4 colour
blocks. Your panels, icons and fonts stay; settings backups stay in
`~/.config/desktop-themes-backup-*`. Flatpak theme access: `flatpak override --user --reset`.

## What's in the pack

| Folder | What |
|---|---|
| `install.sh`, `uninstall.sh` | Install / remove everything (no sudo) |
| `bin/desktop-theme` | The command: install, set up, switch, remove, sync |
| `bin/desktop-audio` | Meta+G target: opens the active theme's audio overlay |
| `themes/<theme>/projects/` | Per theme: global theme, monitor, control + notification center, audio overlay, live wallpaper |
| `themes/<theme>/` | Panel layout, fastfetch, fish helpers, GTK 4 colours, HOWTO |
| `lib/` | Hardware detection (bakes your GPU, disks and CPU sensor into the monitor) and the panel layout script |
| `extras/kde-audio-overlay/` | The Meta+G overlay with a plain Breeze look (not installed) |

## Credits and licences

- Code in this repository: **GPL-3.0-or-later** (see [LICENSE](LICENSE)), unless a file or folder says otherwise.
- All Plasma Styles and window decorations are based on **Carl** by **jomada**
  (Plasma Style LGPL, Aurorae decoration GPL-3.0). Credit is kept in their metadata.
- Fonts, all SIL Open Font License (`OFL.txt` next to each copy): **Antonio**; **Barlow Condensed**
  by Jeremy Tribby; **Oswald** by Vernon Adams, Kalapi Gajjar and Cyreal; **Teko** and **Rajdhani**
  by Indian Type Foundry; **Archivo Narrow** by Omnibus-Type; **Fjalla One** by Sorkin Type;
  **Share Tech** by Carrois Apostrophe.
- The generated wallpapers: CC-BY-SA-4.0.
- Live data: F1 data from the free [Jolpica F1 API](https://github.com/jolpica/jolpica-f1); football
  data from the free [TheSportsDB](https://www.thesportsdb.com) API; weather from the free
  [Open-Meteo](https://open-meteo.com) API (CC BY 4.0). Each live wallpaper only asks for its own
  data every 30 minutes and sends nothing else; turn it off in the wallpaper settings.
  The STARWARS and STARGATE readouts are worked out locally and fetch nothing.
- **Trademarks.** These are unofficial fan themes. They borrow colours and a general look only,
  contain no crests, logos or show/film artwork, and are not affiliated with or endorsed by any
  of these owners: LCARS and Star Trek (CBS Studios / Paramount); Red Bull, Red Bull Racing and
  Formula 1 (their respective owners); the KNVB and the Dutch national team; Feyenoord Rotterdam;
  MVV Maastricht; Star Wars (Lucasfilm Ltd. / Disney); Stargate (MGM / Amazon). Maastricht's coat
  of arms belongs to the municipality and is not used.
- Built from the separate [LCARS](https://github.com/Sjengstah/lcars-desktop) and
  [RBR](https://github.com/Sjengstah/rbr-desktop) desktops.
- Written with a lot of help from Claude (Anthropic).

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. See the LICENSE for the full terms.
