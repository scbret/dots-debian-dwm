#!/bin/sh

slstatus &

# polkit
lxpolkit &


# background
# wal generates color scheme off the named wallpaper without setting the wallpaper - let feh do that
#  wal -i ~/.config/suckless/wallpaper/wallhaven-3q9vmd_3440x1440.png -n &

#feh --bg-scale ~/.config/suckless/wallpaper/wallhaven-218x7m_3440x1440.png &
#feh --bg-scale ~/.config/suckless/wallpaper/wallhaven-9mq26d_3440x1440.png &
##feh --bg-scale ~/.config/suckless/wallpaper/wallhaven-3q9vmd_3440x1440.png &
feh --bg-scale ~/wallpaper/iconic-boss302.jpg &
#feh --bg-scale ~/.config/suckless/wallpaper/wallhaven-85erok_3440x1440.png &
#feh --bg-scale ~/wallpaper/pfback-titles.jpg &

# sxhkd
# (re)load sxhkd for keybinds
if hash sxhkd >/dev/null 2>&1; then
	pkill sxhkd
	sleep 0.5
	sxhkd -c "$HOME/.config/suckless/sxhkd/sxhkdrc" &
fi
xfce4-power-manager &
meteo-qt &
'~/.scripts/start_meteo.sh &'
dunst -config ~/.config/suckless/dunst/dunstrc &
picom --config ~/.config/suckless/picom/picom.conf --animations -b &
