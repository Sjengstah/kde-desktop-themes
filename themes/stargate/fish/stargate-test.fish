function stargate-test --description 'Send three STARGATE-themed test notifications'
    set -l delay 1
    test -n "$argv[1]"; and set delay $argv[1]
    notify-send -a "SGC" -i dialog-information "Incoming Traveler" "SG-1 IDC received. Open the iris."
    sleep $delay
    notify-send -a "Gate Room" -u normal -i dialog-warning "Offworld Activation" "Unscheduled offworld activation!"
    sleep $delay
    notify-send -a "Base Alert" -u critical -i dialog-error "Lockdown" "Foothold situation: base lockdown in effect."
end
