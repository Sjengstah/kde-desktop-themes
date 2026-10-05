function maastricht-test --description 'Send three MAASTRICHT-themed test notifications'
    set -l delay 1
    test -n "$argv[1]"; and set delay $argv[1]
    notify-send -a "Stadhuis" -i dialog-information "Market Day" "The Markt opens at 08:00 today."
    sleep $delay
    notify-send -a "Rain Radar" -u normal -i dialog-warning "Showers Coming" "Rain over the Maas within 20 minutes."
    sleep $delay
    notify-send -a "Waterschap" -u critical -i dialog-error "High Water" "High water on the Maas: the quays are closed."
end
