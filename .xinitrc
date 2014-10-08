#!/bin/sh

# set rules
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# settings for various things
setxkbmap fi
xset s off
xset -dpms
xset r rate 350 45
xset +fp /usr/share/fonts/TTF
xset +fp /usr/share/fonts/local
xset +fp /usr/share/fonts/artwiz-fonts
xsetroot -cursor_name left_ptr
setxkbmap -option terminate:ctrl_alt_bksp

# autostart
autostart() {
xmodmap .xmodmap
xcmenu -d
sxhkd &
nitrogen --restore
}

autostart &
exec herbstluftwm
