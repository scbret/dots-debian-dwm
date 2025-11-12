#!/bin/sh
# ~/.xinitrc — Debian + DWM

# Source system snippets
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# ✅ Ensure a real runtime dir (DON'T point this to /tmp)
# On proper logins, systemd-logind creates /run/user/<uid> for you.
# This fallback just exports it if your TTY login didn't.
if [ -z "${XDG_RUNTIME_DIR}" ]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

# Helpful XDG bits
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=dwm
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# 💡 DO NOT manually start gvfs daemons; they autostart via D-Bus
# (Remove any /usr/libexec/gvfsd lines)

# reload previous color scheme
wal -Rn &

# Display setup
xrandr --output eDP-1 --primary --mode 1536x1024 --pos 0x0 --rotate normal

# Wrap the WM in a D-Bus session (preferred over ad-hoc dbus-launch)
exec dbus-run-session -- dwm

