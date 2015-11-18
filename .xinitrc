#!/bin/sh

# set rules
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# magic
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
   nitrogen --restore
   unclutter -grab -root &
   xmodmap .xmodmap
   xcmenu -d
   sxhkd &
   redshift -l 64:25 -b 0.8:0.8 &> /dev/null &
}

# kill leftovers
autokill() {
   killall unclutter
   killall xcmenu
   killall unclutter
   killall sxhkd
}

autostart &
exec herbstluftwm
autokill; sleep 1
