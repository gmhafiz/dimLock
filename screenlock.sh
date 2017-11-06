#!/usr/bin/env bash

# Author: Hafiz Shafruddin
# Date: Nov 2017
# Version: 1.0

# Description
#
# Dims the screen after a period of time. Then decides to lock the screen if
# laptop is not at home's wifi.
# Moving the mouse durng this dimming period cancels screen locking.
# Screen brightness is restored immediately after screen lock.

# Motivation
#
# i3lock simply locks the screen immediately. I would like the screen to dim 
# before running any locker screen so that I can cancel the locking by moving 
# the mouse.

# Usage
#
#   Use with xautolock. Example in i3wm:
#       exec --no-startup-id xautolock -time 10 -locker screenlock.sh &

# Requirements
#
# - i3lock
# - xdotool
# - xbacklight
# - network-manager (for nmcli)

# TODO
#
# [ ] do not dim/lock if flash plugin container is active
# [ ] do not dim/lock if video is playing

# Customize these:
CONN_INTERFACE=wlp2s0   # Your network interface
HOME_SSID=$HOME_SSID
WAIT_BEFORE_LOCK=30     # How long (seconds) to dim the screen before locking
DIM_TO=5                # The brightness to dim to

#=====================
# DO NOT MODIFY BELOW
#=====================

connection=$(nmcli d show $CONN_INTERFACE | grep GENERAL.CONNECTION | awk '{print $2}')

simple-lock() {
    echo "Simple lock"
}

passwd-lock() {
    i3lock -c 2d2d2d
}

brighten-screen() {
    # detect for mouse movement for a period of time, and restore brightness 
    # level.
    end=$((SECONDS+$WAIT_BEFORE_LOCK))
    while [ $SECONDS -lt $end ]; do
        prevX=$(xdotool getmouselocation 2>&1 | sed -rn '${s/x:([0-9]+) .*/\1 /p}')
        sleep 1
        currX=$(xdotool getmouselocation 2>&1 | sed -rn '${s/x:([0-9]+) .*/\1 /p}')

        if [ $prevX -ne $currX ] ; then
            xbacklight -set $prevBrightness -time 1000 -steps 1000
            exit
        fi
        :
    done
}

dim-screen() {
    prevBrightness=$(xbacklight -get)
    xbacklight -set $DIM_TO -time 1000 -steps 1000

    brighten-screen
}

dim-screen

if [ "$connection" = $HOME_SSID ] ; then
    simple-lock
else
    passwd-lock
    xbacklight -set $prevBrightness -time 1000 -steps 1000
fi
