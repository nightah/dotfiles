#!/bin/bash
# just a dirty script for 'bar-aint-recursive'

# disable path name expansion or * will be expanded in the line.
# cmd ( $line )

set -f

function uniq_linebuffered() {
    awk -W interactive '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

# icons
sep_c="%{B#FF222427}%{F#FF917154}  %{F-}%{B-}"
sep_m="%{B#FF222427}%{F#FF833228}  %{F-}%{B-}"
sep_v="%{B#FF222427}%{F#FF596875}  %{F-}%{B-}"
sep_d="%{B#FF222427}%{F#FF8C5b3E}  %{F-}%{B-}"

# main monitor
monitor=${1:-0}

# padding for statusbar
herbstclient pad $monitor 16

# statusbar
{   
    # now playing
    mpc idleloop player | cat &

    # volume
    while true ; do
        echo "vol $(amixer get PCM | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')%"
	sleep 1 || break
    done > >(uniq_linebuffered) &
    vol_pid=$!
    
    # date
    while true ; do
        date +'date_min %H:%M'
        sleep 1 || break
    done > >(uniq_linebuffered) &
    date_pid=$!

    # hlwm events
    herbstclient --idle

    # exiting; kill stray event-emitting processes
    kill $vol_pid $date_pid    
} 2> /dev/null | {
    TAGS=( $(herbstclient tag_status $monitor) )
    unset TAGS[${#TAGS[@]}]
    time=""
    song="..nothing to see here"
    windowtitle="what have you done?"
    visible=true

    while true ; do
        echo -n "%{l}"
        for i in "${TAGS[@]}" ; do
            case ${i:0:1} in
                '#') # current tag
                    echo -n "%{B#FF833228}"
                    ;;
                '+') # active on other monitor
                    echo -n "%{B#FF917154}"
                    ;;
                ':')
                    echo -n "%{B-}"
                    ;;
                '!') # urgent tag
                    echo -n "%{B#FF917154"
                    ;;
                *)
                    echo -n "%{B-}"
                    ;;
            esac
            echo -n " ${i:1} "
        done
	
	echo -n "%{c}$sep_c%{B#FF262626}${windowtitle//^/^^} %{B-}"
	
        # align right
        echo -n "%{r}"
        echo -n "$sep_m"
        echo -n " $song "
        echo -n "$sep_v"
        echo -n " $volume "
        echo -n "$sep_d"
        echo -n " $date "
        echo ""
        # wait for next event
        read line || break
        cmd=( $line ) 
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                TAGS=( $(herbstclient tag_status $monitor) )
                unset TAGS[${#TAGS[@]}]
                ;;
            mpd_player|player)
                song="$(mpc current)"
                ;;
            vol)
                volume="${cmd[@]:1}"
                ;;
            date_min)
                date="${cmd[@]:1}"
                ;;
		    focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
            quit_panel)
                exit
                ;;
            reload)
                exit
                ;;
        esac
    done
} 2> /dev/null | bar -u 2 -g x16+1280 -B '#FF1A1C1F' -F '#FFA8A8A8' -f '*-stlarch-medium-r-*-*-10-*-*-*-*-*-*-*,-*-cure.se-medium-r-*-*-11-*-*-*-*-*-*-*' $1
