#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

#feh --bg-scale ~/wallpaper/pfback-titles.jpg
#~/.fehbg &
#xcompmgr -c &
#picom --config ~/.config/picom/picom.conf &

#slstatus &
#dunst &

xrandr --output eDP-1 --primary --mode 1536x1024 --pos 0x0 --rotate normal

exec dwm
