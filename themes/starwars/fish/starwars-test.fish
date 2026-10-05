function starwars-test --description 'Send three STARWARS-themed test notifications'
    set -l delay 1
    test -n "$argv[1]"; and set delay $argv[1]
    notify-send -a "Comlink" -i dialog-information "Incoming Transmission" "Rendezvous at the base at 1900 hours."
    sleep $delay
    notify-send -a "Deflectors" -u normal -i dialog-warning "Shields Low" "Forward shields at 40 percent."
    sleep $delay
    notify-send -a "Damage Control" -u critical -i dialog-error "Hull Breach" "Hull breach on deck 3! Seal the blast doors."
end
