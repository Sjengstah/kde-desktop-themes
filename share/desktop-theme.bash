_desktop_theme() {
    local themes="lcars rbr oranje feyenoord mvv maastricht starwars stargate"
    if (( COMP_CWORD == 1 )); then
        COMPREPLY=($(compgen -W "$themes list status setup install remove sync help" -- "${COMP_WORDS[1]}"))
    else
        COMPREPLY=($(compgen -W "$themes all" -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
}
complete -F _desktop_theme desktop-theme
