#! /bin/bash

mbsync -c ~/.config/isync/isyncrc -a
sh ./inbox_unread_count.sh
pkill -SIGRTMIN+9 i3blocks
