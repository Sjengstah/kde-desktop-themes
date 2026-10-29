# Bash tab-completion for the "desktop-theme" command
#
# What it does:
#   Lets you press Tab after "desktop-theme" in bash:
#   - first word: a theme name or one of the commands (list, status, setup, install,
#     remove, sync, help)
#   - after that: a theme name or "all"
#   Not a script you run: install.sh copies it to
#   ~/.local/share/bash-completion/completions/desktop-theme and bash loads it.
_desktop_theme() {
    local themes="lcars rbr oranje feyenoord mvv maastricht starwars stargate"
    if (( COMP_CWORD == 1 )); then
        COMPREPLY=($(compgen -W "$themes list status setup install remove sync help" -- "${COMP_WORDS[1]}"))
    else
        COMPREPLY=($(compgen -W "$themes all" -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
}
complete -F _desktop_theme desktop-theme
