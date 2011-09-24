#!/bin/bash

awesome &
xcompmgr &

eval `dbus-launch --sh-syntax --exit-with-session`
exec ck-launch-session gnome-session
gnome-settings-daemon &

eval `mpd && mpc ls | mpc add; mpc shuffle`
eval `mpdscribble`
