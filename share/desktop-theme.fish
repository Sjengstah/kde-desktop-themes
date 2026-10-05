complete -c desktop-theme -f -n "__fish_use_subcommand" -a "lcars rbr oranje feyenoord mvv maastricht starwars stargate" -d "switch to theme"
complete -c desktop-theme -f -n "__fish_use_subcommand" -a "list status setup install remove sync help"
complete -c desktop-theme -f -n "__fish_seen_subcommand_from setup install remove" -a "lcars rbr oranje feyenoord mvv maastricht starwars stargate"
complete -c desktop-theme -f -n "__fish_seen_subcommand_from install remove" -a "all"
