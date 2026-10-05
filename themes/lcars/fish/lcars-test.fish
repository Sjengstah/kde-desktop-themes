function lcars-test --description 'Send three LCARS-themed test notifications'
    set -l delay 1
    test -n "$argv[1]"; and set delay $argv[1]
    notify-send -a "USS Enterprise" -i dialog-information "Incoming Transmission" "Starfleet Command: priority message on subspace channel 7."
    sleep $delay
    notify-send -a "Engineering" -u normal -i dialog-warning "Warp Core Status" "Antimatter containment holding at 98.4%. Dilithium matrix nominal."
    sleep $delay
    notify-send -a "Tactical" -u critical -i dialog-error "Red Alert" "Unidentified vessel approaching. Shields at maximum."
end
