#!/bin/sh
#          ██          ██   ██                 
#         ░░          ░░   ░██                 
#  ██   ██ ██ ███████  ██ ██████ ██████  █████ 
# ░░██ ██ ░██░░██░░░██░██░░░██░ ░░██░░█ ██░░░██
#  ░░███  ░██ ░██  ░██░██  ░██   ░██ ░ ░██  ░░ 
#   ██░██ ░██ ░██  ░██░██  ░██   ░██   ░██   ██
#  ██ ░░██░██ ███  ░██░██  ░░██ ░███   ░░█████ 
# ░░   ░░ ░░ ░░░   ░░ ░░    ░░  ░░░     ░░░░░  
# Destroy everything!

# 設定 
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# UIM 設定
#export GTK_IM_MODULE='uim'
#export XMODIFIERS=@im='uim'
#export QT_IM_MODULE='uim'
#uim-xim &> /dev/null &

# まほう
setxkbmap fi
xset s off
xset -dpms
xset r rate 350 45
xset +fp /usr/share/fonts/TTF
xset +fp /usr/share/fonts/local
xset +fp /usr/share/fonts/artwiz-fonts
xsetroot -cursor_name left_ptr
setxkbmap -option terminate:ctrl_alt_bksp

# URXvt 設定  
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# オートスタート
autostart() {
   nitrogen --restore
   urxvtd -q -f -o
   unclutter -grab -root &
   xmodmap .xmodmap
   xcmenu -d
   sxhkd &
   redshift -l 64:25 -b 0.8:0.8 &> /dev/null &
}

# さよなら
autokill() {
   killall unclutter
   killall xcmenu
   killall unclutter
   killall sxhkd
   killall urxvtd
   killall lemonbar
}

# 始まる
autostart &
exec 2bwm
autokill; sleep 2
