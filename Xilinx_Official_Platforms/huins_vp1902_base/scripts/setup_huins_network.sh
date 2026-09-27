#!/bin/sh

set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script as root, for example: sudo $0" >&2
  exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
network_config=${1:-"$script_dir/../network/10-end0.network"}

if [ ! -f "$network_config" ]; then
  network_config="$script_dir/../sw/prebuilt_linux/rootfs_overlay/etc/systemd/network/10-end0.network"
fi

if [ ! -f "$network_config" ]; then
  echo "Cannot find 10-end0.network; pass its path as the first argument" >&2
  exit 1
fi

install -D -m 0644 "$network_config" /etc/systemd/network/10-end0.network
systemctl enable --now systemd-networkd.service
networkctl reload
networkctl reconfigure end0

systemctl is-active systemd-networkd.service
networkctl --no-pager status end0
ip -4 -br addr show end0
