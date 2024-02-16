#! /bin/bash

for disp in $(swww query | awk -F: '{ print $1 }'); do
	notify-send "swww" "Changing wallpaper for screen $disp"
	swww img -o $disp "$(random_bg)"
done
