function rbr-test --description 'Send three RBR-themed test notifications'
    set -l delay 1
    test -n "$argv[1]"; and set delay $argv[1]
    notify-send -a "Pit Wall" -i dialog-information "Team Radio" "Box, box. Box this lap for mediums."
    sleep $delay
    notify-send -a "Race Control" -u normal -i dialog-warning "Track Limits" "Car 1: lap time deleted at turn 4. Black and white flag shown."
    sleep $delay
    notify-send -a "Race Control" -u critical -i dialog-error "Red Flag" "Session suspended. All cars return to the pit lane."
end
