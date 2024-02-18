#!/bin/bash
stack_file="/tmp/hide_window_pid_stack.txt"

pid=$(hyprctl activewindow -j | jq '.pid')
stackpop=$(tail -1 $stack_file)
if [ "$stackpop" == "$pid" ]
then
	current_workspace=$(hyprctl activeworkspace -j | jq '.id')	
	hyprctl dispatch movetoworkspacesilent $current_workspace,pid:$pid
  echo $pid | sed -i '$d' $stack_file
else
	hyprctl dispatch movetoworkspacesilent 88,pid:$pid
	echo $pid >> $stack_file
fi

