#!/bin/bash
setxkbmap -layout br
xrandr --output Virtual-1 --mode 1680x1050
picom -f --experimental-backend &
exec awesome
#qtile start
