#!/usr/bin/env bash

POSITIONAL_ARGS=()

SPECIAL=false
PREFIX=false
BATCH=0
while [[ $# -gt 0 ]]; do
  case $1 in
  -w | --workspace)
    WORKSPACE="$2"
    shift
    shift
    ;;
  -b | --batch)
    BATCH="$2"
    shift
    shift
    ;;
  -s | --special)
    SPECIAL=true
    shift
    ;;
  -p | --prefix)
    PREFIX=true
    shift
    ;;
  -* | --*)
    echo "Unknown option $1"
    exit 1
    ;;
  *)
    POSITIONAL_ARGS+=("$1") # save positional arg
    shift                   # past argument
    ;;
  esac
done

show_help() {
  printf "Usage: %s <ACTION> [-w|--worspace] <WORSPACE|WORKSPACE_OFFSET>" "${0##*/}"
}

parse_spl_workspace() {
  if [ -z "$WORKSPACE" ]; then
    WORKSPACE=$(hyprctl workspaces -j |
      jq -r '.[].name |
      capture("(?<n>special:.*)") |
      .n / ":" |
      .[1:] | join(":")' |
      $SELECTOR)
  fi
  if [ -z "$WORKSPACE" ]; then
    exit 1
  elif [ "$PREFIX" = true ]; then
    WORKSPACE=special:$WORKSPACE
  fi
}

parse_workspace() {
  WORKSPACE=${WORKSPACE:-${POSITIONAL_ARGS[1]}}
  if [ -z "$WORKSPACE" ]; then
    show_help
    exit 1
  fi

  local curr_workspace
  curr_workspace=$(hyprctl activeworkspace -j | jq -r .id)
  if [ -z "$BATCH" ]; then BATCH=$(((curr_workspace - 1) / 10)); fi
  case "${WORKSPACE:0:1}" in
  + | -) WORKSPACE=$((curr_workspace + WORKSPACE)) ;;
  *) WORKSPACE=$((BATCH * 10 + WORKSPACE)) ;;
  esac
}

if [ "$SPECIAL" = false ]; then
  parse_workspace
else
  parse_spl_workspace
fi

hyprctl dispatch "${POSITIONAL_ARGS[0]}" "$WORKSPACE"
