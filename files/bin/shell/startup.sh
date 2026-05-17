awww-daemon --quiet &
vicinae server 2>/dev/null &
xwayland-satellite 2>/dev/null &
ghostty -e btop &
ghostty -e tty-clock &
ffplay -nodisp ~/Atlas/files/audio/startup.mp3 2>/dev/null &
mullvad connect &

sleep 12

openrgb -d 0 -c $(python3 ~/Atlas/files/bin/fix_rgb_color.py $(cat ~/Atlas/files/config/primary_color.txt | tr -d '#')) &
# virsh --connect qemu:///system start win11 &
