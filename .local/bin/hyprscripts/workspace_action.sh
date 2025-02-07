#!/usr/bin/env bash

curr_workspace=$(hyprctl activeworkspace -j | jq -r .id)

hyprctl dispatch "$1" $(((($curr_workspace - 1) / 10) * 10 + $2))
