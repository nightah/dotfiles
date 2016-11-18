#!/bin/bash
#          ██          ██   ██                 
#         ░░          ░░   ░██                 
#  ██   ██ ██ ███████  ██ ██████ ██████  █████ 
# ░░██ ██ ░██░░██░░░██░██░░░██░ ░░██░░█ ██░░░██
#  ░░███  ░██ ░██  ░██░██  ░██   ░██ ░ ░██  ░░ 
#   ██░██ ░██ ░██  ░██░██  ░██   ░██   ░██   ██
#  ██ ░░██░██ ███  ░██░██  ░░██ ░███   ░░█████ 
# ░░   ░░ ░░ ░░░   ░░ ░░    ░░  ░░░     ░░░░░  
# destroy everything!

# don't ask me 
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# xrdb
[ -f ~/.Xresources ] && xrdb -merge -I$HOME ~/.Xresources

# magic
setxkbmap fi
xset s off
xset -dpms
xset r rate 350 45
xsetroot -cursor_name left_ptr
setxkbmap -option terminate:ctrl_alt_bksp

# automagic
autostart() {
   xcmenu -d
   #urxvtd -q -f -o
   xmodmap .xmodmap
   nitrogen --restore
   xbanish &
   sxhkd -c ~/.config/sxhkd/sxhkdrc \
            ~/.config/sxhkd/sxhkdrc.herb &
   redshift -l 64:25 -b 0.8:0.8 &> /dev/null &
}

# eat the world
autokill() {
   killall xcmenu
   #killall urxvtd
   killall sxhkd
   killall lemonbar
   killall redshift
   killall unclutter
}

# EXEcute
autostart &
exec herbstluftwm
autokill; sleep 1
