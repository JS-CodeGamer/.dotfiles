#!/bin/bash

swaylock -efFi "$(random_bg)"
sleep 5s
hyprctl dispatch dpms off
