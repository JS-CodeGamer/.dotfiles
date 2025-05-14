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

help() {
  printf "Usage: %s <ACTION> [-w|--worspace] <WORSPACE|WORKSPACE_OFFSET>"
}

set -x
if [ "$SPECIAL" = false ]; then
  WORKSPACE=${WORKSPACE:-${POSITIONAL_ARGS[1]}}
  if [ -z "$WORKSPACE" ]; then
    help
    exit 1
  fi

  curr_workspace=$(hyprctl activeworkspace -j | jq -r .id)
  if [[ "$WORKSPACE" =~ "(+|-).*" ]]; then
    WORKSPACE=$(($curr_workspace + "$WORKSPACE"))
  else
    WORKSPACE=$((($curr_workspace - 1) / 10 * 10 + $WORKSPACE))
  fi
else
  if [ -z "$WORKSPACE" ]; then
    WORKSPACE=$(hyprctl workspaces -j |
      jq -r '.[].name |
      capture("(?<n>special:.*)") |
      .n / ":" |
      .[1:] | join(":")' |
      tofi)
  fi
  if [ -z "$WORKSPACE" ]; then
    exit 1
  fi
  if [ "$PREFIX" = true ]; then
    WORKSPACE=special:$WORKSPACE
  fi
fi

hyprctl dispatch "${POSITIONAL_ARGS[0]}" "$WORKSPACE"
