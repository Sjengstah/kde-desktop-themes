function mvv-test --description 'Send three MVV-themed test notifications'
    set -l delay 1
    test -n "$argv[1]"; and set delay $argv[1]
    notify-send -a "Match Centre" -i dialog-information "Team News" "Starting XI announced: an unchanged side for tonight."
    sleep $delay
    notify-send -a "Referee" -u normal -i dialog-warning "Yellow Card" "Booking for a late tackle in the 67th minute."
    sleep $delay
    notify-send -a "Referee" -u critical -i dialog-error "Red Card" "Straight red! Down to ten men."
end
