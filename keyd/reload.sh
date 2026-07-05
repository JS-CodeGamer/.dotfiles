#!/usr/bin/env bash

CONF_DIR="$(realpath $(dirname -- "${BASH_SOURCE[0]}"))"

sudo ln -sf "$CONF_DIR"/"$1" /etc/keyd/default.conf
sudo systemctl is-active keyd.service &>/dev/null || {
  sudo systemctl start keyd.service && printd '>> keyd.service started\n'
}
sudo keyd reload
