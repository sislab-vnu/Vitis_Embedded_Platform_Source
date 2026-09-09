#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <input-rootfs.ext4> <output-rootfs.ext4>" >&2
  exit 1
fi

input=$1
output=$2
script_dir=$(dirname "$(readlink -f "$0")")
network_config="$script_dir/rootfs_overlay/etc/systemd/network/10-end0.network"
getty_unit="$script_dir/rootfs_overlay/etc/systemd/system/huins-uart-getty.service"
getty_path=/etc/systemd/system/huins-uart-getty.service
getty_link=/etc/systemd/system/getty.target.wants/huins-uart-getty.service
temporary="${output}.tmp"

test -f "$input"
test -f "$network_config"
test -f "$getty_unit"
command -v debugfs >/dev/null

mkdir -p "$(dirname "$output")"
rm -f "$temporary"
trap 'rm -f "$temporary"' EXIT

cp --reflink=auto --sparse=always "$input" "$temporary"
remove=
if debugfs -R "stat /etc/systemd/network/10-end0.network" \
  "$temporary" 2>/dev/null | grep -q '^Inode:'; then
  remove="rm 10-end0.network"
fi
remove_getty_unit=
if debugfs -R "stat $getty_path" "$temporary" 2>/dev/null | grep -q '^Inode:'; then
  remove_getty_unit="rm huins-uart-getty.service"
fi
remove_getty=
if debugfs -R "stat $getty_link" "$temporary" 2>/dev/null | grep -q '^Inode:'; then
  remove_getty="rm huins-uart-getty.service"
fi
debugfs -w "$temporary" >/dev/null <<EOF
cd /etc/systemd/network
$remove
write $network_config 10-end0.network
cd /etc/systemd/system
$remove_getty_unit
write $getty_unit huins-uart-getty.service
cd /etc/systemd/system/getty.target.wants
$remove_getty
symlink huins-uart-getty.service $getty_path
EOF

actual=$(debugfs -R "cat /etc/systemd/network/10-end0.network" \
  "$temporary" 2>/dev/null)
expected=$(<"$network_config")
test "$actual" = "$expected"
actual_getty=$(debugfs -R "cat $getty_path" "$temporary" 2>/dev/null)
expected_getty=$(<"$getty_unit")
test "$actual_getty" = "$expected_getty"
getty_stat=$(debugfs -R "stat $getty_link" "$temporary" 2>/dev/null)
grep -q 'Type: symlink' <<<"$getty_stat"
grep -q "Fast link dest: \"$getty_path\"" <<<"$getty_stat"

mv "$temporary" "$output"
trap - EXIT
