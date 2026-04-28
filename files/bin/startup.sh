awww-daemon &
vicinae server 2>/dev/null &
xwayland-satellite 2>/dev/null &
skwd-wall-daemon &
kitty -T btop btop &
kitty -T clock tty-clock &
ffplay -nodisp ~/Atlas/files/audio/startup.mp3 2>/dev/null &
mullvad connect &

sleep 120

openrgb -d 0 -c $(python3 ~/Atlas/files/bin/fix_rgb_color.py $(cat ~/Atlas/files/config/primary_color.txt | tr -d '#')) &
virsh --connect qemu:///system start win11 &
