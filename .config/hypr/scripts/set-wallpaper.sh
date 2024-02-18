#! /bin/bash

for disp in $(swww query | awk -F: '{ print $1 }'); do
	swww img -o $disp "$(random_bg)"
done
