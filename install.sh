#!/usr/bin/env bash
# KDE desktop themes: install the pack for the current user. No sudo, ever.
#
#   ./install.sh                     interactive: installs all themes, then asks which
#                                    one to set up on your panels (or none)
#   ./install.sh lcars rbr           install only these themes
#   ./install.sh --setup oranje      also build the ORANJE panels on the primary screen
#   ./install.sh --yes               no questions (installs, sets up nothing)
#   ./install.sh --dry-run           show what would happen, change nothing
#
# Afterwards everything is done with the desktop-theme command (see README.md).
# WARNING: largely AI-generated ("vibe coded"). Read it before you run it.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN="$HOME/.local/bin"
PACK="$DATA/desktop-themes"
ALL=(lcars rbr oranje feyenoord mvv maastricht starwars stargate)

YES=false; DRY=false; SETUP=""; THEMES=()
while (( $# )); do
    case "$1" in
        --yes|-y) YES=true ;;
        --dry-run|-n) DRY=true ;;
        --setup) SETUP="${2:-}"; shift ;;
        -h|--help) sed -n '2,/^set -euo/{/^#/s/^# \{0,1\}//p}' "$0" | sed '$d'; exit 0 ;;
        all) THEMES=("${ALL[@]}") ;;
        -*) echo "Unknown option: $1" >&2; exit 1 ;;
        *) [[ " ${ALL[*]} " == *" $1 "* ]] || { echo "Unknown theme: $1 (${ALL[*]})" >&2; exit 1; }
           THEMES+=("$1") ;;
    esac
    shift
done
(( ${#THEMES[@]} )) || THEMES=("${ALL[@]}")
[[ -z "$SETUP" || " ${THEMES[*]} " == *" $SETUP "* ]] || THEMES+=("$SETUP")

gold=$'\e[38;2;255;204;102m'; blue=$'\e[38;2;153;204;255m'; red=$'\e[38;2;255;90;95m'; off=$'\e[0m'
step() { printf '\n%s▌ %s%s\n' "$gold" "$*" "$off"; }
info() { printf '  %s\n' "$*"; }
warn() { printf '  %s! %s%s\n' "$red" "$*" "$off"; }
run() { if $DRY; then printf '  %s[dry-run]%s %s\n' "$blue" "$off" "$*"; else "$@"; fi; }

# ── Preflight ───────────────────────────────────────────────────────
step "KDE desktop themes — preflight"
[[ -d "$HERE/themes" ]] || { warn "themes/ is missing next to install.sh"; exit 1; }
(( EUID != 0 )) || { warn "Run this as your normal user, not as root."; exit 1; }
[[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* ]] || warn "This doesn't look like a KDE session (XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-unset})."
[[ "${XDG_SESSION_TYPE:-}" == "wayland" ]] || warn "Not a Wayland session: the audio overlay and themed popups need Wayland."
command -v plasmashell >/dev/null || { warn "plasmashell not found: install KDE Plasma 6 first."; exit 1; }
info "Plasma: $(plasmashell --version 2>/dev/null)"
. /etc/os-release 2>/dev/null || true
info "System: ${PRETTY_NAME:-unknown}"
info "Themes: ${THEMES[*]}"

cat <<EOF

  This will:
   1. check the required packages (it lists missing ones, it never installs them)
   2. back up your current Plasma, KWin, GTK and fastfetch settings
   3. install the desktop-theme command and the chosen themes: global themes (also in
      System Settings → Global Theme), widgets, audio overlays, live wallpapers, fonts
   4. bind Meta+G to the audio overlay of the active theme
   5. let GTK and Flatpak apps follow the theme
   6. only if you choose a theme to set up: REPLACE the panels on the primary screen
      with that theme's panels and widgets

  Your icons are never changed. Nothing is activated unless you set up a theme.
EOF
if ! $YES && ! $DRY; then
    read -r -p "  Continue? [y/N] " answer
    [[ "$answer" =~ ^[Yy] ]] || { echo "  Cancelled."; exit 0; }
fi

# ── 1. Requirements (checked only, never installed) ─────────────────
step "Checking requirements"
MISSING=()
if command -v pacman >/dev/null; then
    wanted=(qt6-declarative layer-shell-qt plasma-pa kirigami kitemmodels bluez-qt bluedevil plasma-nm
            powerdevil libksysguard ksystemstats libarchive fastfetch libnotify python)
    for p in "${wanted[@]}"; do pacman -Q "$p" >/dev/null 2>&1 || MISSING+=("$p"); done
    pacman -Q power-profiles-daemon >/dev/null 2>&1 || pacman -Q tuned-ppd >/dev/null 2>&1 || MISSING+=(power-profiles-daemon)
    INSTALL_CMD="sudo pacman -S --needed"
elif command -v rpm >/dev/null; then
    wanted=(qt6-qtdeclarative layer-shell-qt plasma-pa kf6-kirigami kf6-kitemmodels kf6-bluez-qt bluedevil
            plasma-nm powerdevil libksysguard ksystemstats bsdtar power-profiles-daemon fastfetch libnotify python3)
    for p in "${wanted[@]}"; do rpm -q "$p" >/dev/null 2>&1 || MISSING+=("$p"); done
    INSTALL_CMD="sudo dnf install"
else
    warn "Unknown distro: check the requirements list in README.md yourself."
fi
if (( ${#MISSING[@]} )); then
    warn "Missing (this script does not install packages): ${MISSING[*]}"
    info "Install them yourself if you want the parts that need them:"
    info "  $INSTALL_CMD ${MISSING[*]}"
    if ! $YES && ! $DRY; then
        read -r -p "  Continue without them? [y/N] " answer
        [[ "$answer" =~ ^[Yy] ]] || { echo "  Cancelled. Install them, then run install.sh again."; exit 0; }
    fi
else
    info "All requirements present."
fi
for c in python3 kpackagetool6 bsdtar qdbus6 kwriteconfig6; do
    command -v "$c" >/dev/null || warn "$c not found: installing will fail without it."
done

# ── 2. Backup ───────────────────────────────────────────────────────
step "Backing up current settings"
BACKUP="$CONF/desktop-themes-backup-$(date +%Y%m%d-%H%M%S)"
run mkdir -p "$BACKUP"
for f in kdeglobals kwinrc plasmarc ksplashrc kcminputrc plasmashellrc kglobalshortcutsrc \
         plasma-org.kde.plasma.desktop-appletsrc plasmanotifyrc gtk-3.0/settings.ini gtk-4.0/gtk.css \
         fastfetch/config.jsonc; do
    if [[ -f "$CONF/$f" ]]; then run install -D -m600 "$CONF/$f" "$BACKUP/$f"; fi
done
info "Backup: $BACKUP"

# ── 3. Pack, command and themes ─────────────────────────────────────
step "Installing the desktop-theme command"
# A copy of the pack, so `desktop-theme install` keeps working after you delete this folder.
run rm -rf "$PACK"
run mkdir -p "$PACK"
run cp -a "$HERE/themes" "$HERE/lib" "$HERE/extras" "$HERE/LICENSE" "$PACK/"
run mkdir -p "$BIN" "$CONF/fish/completions" "$DATA/bash-completion/completions" "$CONF/systemd/user"
for b in desktop-theme desktop-audio panel-opacity; do run install -m755 "$HERE/bin/$b" "$BIN/$b"; done
run install -m644 "$HERE/share/desktop-theme.fish" "$CONF/fish/completions/desktop-theme.fish"
run install -m644 "$HERE/share/desktop-theme.bash" "$DATA/bash-completion/completions/desktop-theme"
info "commands: desktop-theme, desktop-audio, panel-opacity (in $BIN)"
[[ ":$PATH:" == *":$BIN:"* ]] || warn "$BIN is not in your PATH: add it, or run $BIN/desktop-theme"

step "Installing themes"
if $DRY; then
    info "[dry-run] would run: desktop-theme install ${THEMES[*]}"
else
    "$BIN/desktop-theme" install "${THEMES[@]}" | sed 's/^/  /'
fi

# ── 4. Meta+G ───────────────────────────────────────────────────────
step "Meta+G audio overlay"
run mkdir -p "$DATA/applications"
if ! $DRY; then sed "s|@BIN@|$BIN|" "$HERE/share/desktop-audio.desktop" > "$DATA/applications/desktop-audio.desktop"; fi
# Keep an existing Meta+G binding to a theme launcher (it now runs desktop-audio as well);
# otherwise bind desktop-audio.desktop.
if grep -A1 -E '^\[services\]\[[a-z]+-audio\.desktop\]' "$CONF/kglobalshortcutsrc" 2>/dev/null | grep -q '_launch=Meta+G'; then
    info "Meta+G already bound to a theme overlay; kept"
else
    run kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Grid View" "none,Meta+G,Toggle Grid View"
    run kwriteconfig6 --file kglobalshortcutsrc --group services --group desktop-audio.desktop --key _launch "Meta+G"
    info "Meta+G → desktop-audio (log out and back in once to activate)"
fi
run kbuildsycoca6 >/dev/null 2>&1 || true

# ── 5. GTK, Flatpak, System Settings ────────────────────────────────
step "GTK, Flatpak and System Settings"
if command -v flatpak >/dev/null; then
    run flatpak override --user --filesystem=xdg-config/gtk-3.0:ro --filesystem=xdg-config/gtk-4.0:ro \
        --filesystem=xdg-config/kdeglobals:ro --filesystem=xdg-data/icons:ro --filesystem=xdg-data/fonts:ro
    info "Flatpak apps may read the theme"
fi
run install -m644 "$HERE/systemd/desktop-theme-sync.path" "$HERE/systemd/desktop-theme-sync.service" "$CONF/systemd/user/"
run systemctl --user daemon-reload
run systemctl --user enable --now desktop-theme-sync.path 2>/dev/null
info "picking a theme in System Settings → Global Theme also switches widgets, wallpaper and fastfetch"

# ── 6. Panels (optional) ────────────────────────────────────────────
if [[ -z "$SETUP" ]] && ! $YES && ! $DRY; then
    cat <<EOF

  Set up a theme's panels now? This REPLACES the panels on your primary screen with
  that theme's panels and widgets (your settings are in the backup above).
  Already have the widgets on your panels? Choose none and run: desktop-theme <theme>
EOF
    read -r -p "  Theme to set up (${THEMES[*]}), or Enter for none: " SETUP
    [[ -z "$SETUP" || " ${THEMES[*]} " == *" $SETUP "* ]] || { warn "Unknown theme '$SETUP', skipping"; SETUP=""; }
fi
if [[ -n "$SETUP" ]]; then
    step "Setting up ${SETUP^^} on the primary screen"
    run "$BIN/desktop-theme" setup "$SETUP"
fi

(( ${#MISSING[@]} )) && warn "Still missing: ${MISSING[*]} — the parts that need them won't work until you install them."
cat <<EOF

${gold}▌ Done.${off}
  desktop-theme list             see the themes
  desktop-theme <theme>          switch everything to a theme
  desktop-theme setup <theme>    build a theme's panels on the primary screen
  System Settings → Colors & Themes → Global Theme also lists them.

  • Log out and back in once so Meta+G and the widget hotkeys are active.
  • Hide the crossed-out bell in the system tray (Configure → Entries →
    Notifications → Always hidden). Don't disable it.
  • Settings backup: $BACKUP
  • Uninstall: ./uninstall.sh
EOF
