#!/bin/dash
# dash is faster
# motherfucker.

# settings
BG="#1D1F21"
FG="#A8A8A8"
RES="160x24+3016+20"
FONT="-*-cure.se-medium-r-*-*-11-*-*-*-*-*-*-*" 

# clock
while :; do
	echo "%{c}$(date "+%b %d %A %H:%M")%{c}"
	sleep 45s
done |

lemonbar -b -g "${RES}" -f "${FONT}" -B "${BG}" -F "${FG}"
