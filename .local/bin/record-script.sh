#!/usr/bin/env bash

getdate() {
  date -uIs
}
getaudiooutput() {
  pactl list sources | grep 'Name' | grep 'monitor' | cut -d ' ' -f2
}
getactivemonitor() {
  hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

if pgrep wf-recorder >/dev/null; then
  notify-send "Recording Stopped" "Stopped" -a 'record-script.sh' &
  pkill wf-recorder &
else
  notify-send "Starting recording" 'recording_'"$(getdate)"'.mp4' -a 'record-script.sh'
  filename="$(xdg-user-dir VIDEOS)/recording_$(getdate).mp4"
  if [[ "$1" == "--sound" ]]; then
    wf-recorder --pixel-format yuv420p -f $filename -t --geometry "$(slurp)" --audio="$(getaudiooutput)" &
    disown
  elif [[ "$1" == "--fullscreen-sound" ]]; then
    wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f $filename -t --audio="$(getaudiooutput)" &
    disown
  elif [[ "$1" == "--fullscreen" ]]; then
    wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f $filename -t &
    disown
  else
    wf-recorder --pixel-format yuv420p -f $filename -t --geometry "$(slurp)" &
    disown
  fi
fi
