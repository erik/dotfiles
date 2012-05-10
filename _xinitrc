#!/bin/bash

awesome &
xcompmgr &

eval `keychain --eval --agents ssh id_rsa`
eval `dbus-launch --sh-syntax --exit-with-session`

exec ck-launch-session gnome-session
