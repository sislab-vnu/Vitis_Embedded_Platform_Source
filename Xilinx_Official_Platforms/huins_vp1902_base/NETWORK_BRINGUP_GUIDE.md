# Huins VP1902 Network Bring-Up

This guide configures the Huins VP1902 GEM interface with the stable
`192.168.1.57/24` address used by the direct lab link. It also verifies the
lab-host link and the Target Communication Framework (TCF) agent used to run
applications remotely.

## Network Layout

```text
development host -> SSH gateway/lab host -> direct Ethernet -> Huins VP1902
                                             192.168.1.1      192.168.1.57
```

The board interface is named `end0`. The lab host interface name depends on its
USB Ethernet adapter and must be discovered rather than assumed.

Perform the first board-side configuration over the CP210 UART. Reconfiguring
the interface through SSH or TCF can disconnect the session running the command.

## 1. Connect to the Board UART

On the lab host, locate the CP210 device and open it at 115200 baud:

```bash
ls -l /dev/serial/by-id/

picocom -b 115200 \
  /dev/serial/by-id/usb-Silicon_Labs_CP2102N_USB_to_UART_Bridge_Controller_*-if00-port0
```

Log in as `amd-edf` with the provisioned board password. Do not put the password
in this guide or in a checked-in script.

## 2. Install the Systemd Network Setup

The export includes the authoritative network file and setup script. Run from
the exported platform directory on the board:

```bash
sudo scripts/setup_huins_network.sh
```

This static configuration avoids DHCP timing and random-MAC reservation
dependencies on the direct lab link.

An earlier pre-PHY-reset EDF validation used an on-card file with SHA-256
`555a2d712401d5eec730a7f513fa3925aaa536e4cf8d2615ec990086d054b4dd`.
It remained selected by `systemd-networkd` with `192.168.1.57/24` after a
controlled `sudo reboot` and after a true main-power cold cycle. Both
`systemd-networkd` and `tcf-agent.service` returned active after that historical
cold boot. This does not validate cold-SD deployment of the corrected linked
package.

The installed file is:

```ini
[Match]
Name=end0

[Network]
Address=192.168.1.57/24
Gateway=192.168.1.1
```

The source platform installs the same file from:

```text
sw/prebuilt_linux/rootfs_overlay/etc/systemd/network/10-end0.network
```

## 3. Verify the Board Interface

Run on the board:

```bash
systemctl is-enabled systemd-networkd.service
systemctl is-active systemd-networkd.service
networkctl --no-pager status end0
ip -4 -br addr show end0
ip route
cat /sys/class/net/end0/carrier
cat /sys/class/net/end0/operstate
ethtool end0 | grep -E 'Speed:|Duplex:|Link detected:'
```

Expected minimum state:

```text
systemd-networkd: enabled and active
end0:             UP with 192.168.1.57/24
carrier:          1
operstate:        up
speed:            1000Mb/s
duplex:           Full
```

The board uses a random MAC address when no fixed address is supplied by
firmware. Use `192.168.1.57` as the deterministic management address rather
than depending on a previously observed MAC.

## 4. Configure the Lab Host Link

On the lab host, identify the Ethernet interface connected to the board:

```bash
ip -br link
```

Set `HOST_IF` to that interface. The validated lab used a USB Ethernet adapter:

```bash
export HOST_IF=<board-facing-host-interface>

sudo ip link set dev "$HOST_IF" up
sudo ip addr replace 192.168.1.1/24 dev "$HOST_IF"

ip -br addr show dev "$HOST_IF"
ethtool "$HOST_IF" | grep -E 'Speed:|Duplex:|Link detected:'
```

Use the host's existing network manager for a permanent host configuration. Do
not enable a second manager such as `systemd-networkd` if NetworkManager already
owns the adapter.

## 5. Verify End-to-End Connectivity

From the board:

```bash
ping -c 3 192.168.1.1
ip neigh show dev end0
```

From the lab host:

```bash
ping -c 3 192.168.1.57
ip neigh show 192.168.1.57
```

Both directions must pass. An address shown by `ip addr` is not sufficient
proof of connectivity.

## 6. Start and Verify TCF

On the board:

```bash
sudo systemctl start tcf-agent.service
systemctl is-active tcf-agent.service
```

From the lab host:

```bash
timeout 5 bash -c '</dev/tcp/192.168.1.57/1534'
```

TCF port 1534 provides root-level file and process access without its own
authentication. Keep it on the isolated board-facing network and expose it to a
development host only through a loopback-bound SSH tunnel.

See [TCF_TUNNEL_GUIDE.md](TCF_TUNNEL_GUIDE.md) for tunnel setup and remote
program/xclbin execution.

## 7. Verify the Development-Host Tunnel

After creating the SSH tunnel described in `TCF_TUNNEL_GUIDE.md`, verify the TCF
protocol with Vitis 2025.2 `xsdb`. A local TCP listener alone is not sufficient
because SSH can keep the forwarding socket open while the board is unreachable.

```bash
source <Vitis_install>/Vitis/2025.2/settings64.sh

cat >/tmp/check-huins-tcf.tcl <<'EOF'
connect -host 127.0.0.1 -port 15340
puts [tfile roots]
disconnect
exit
EOF

xsdb /tmp/check-huins-tcf.tcl
```

Once that succeeds, run a test pair with:

```bash
xsdb scripts/tcf_run_xclbin.tcl \
  127.0.0.1 15340 \
  /absolute/path/to/test-program \
  /absolute/path/to/test.xclbin
```

## Troubleshooting

### Address exists but ARP fails

Check both ends before changing board software:

```bash
# Board
ip -s link show end0
ping -c 3 192.168.1.1

# Lab host
ip -s link show "$HOST_IF"
ping -c 3 192.168.1.57
```

During early validation, the board correctly showed `UP`, `LOWER_UP`, carrier
1, and `192.168.1.57/24`, but received zero packets. Host configuration alone
did not reliably resolve later recurrences; the corrected linked PDI and PHY
reset DT were required for repeatable receive traffic.

If both ends report carrier but opposing pings leave both receive counters
unchanged, the failure is below the IP configuration. Recycle the dedicated
host connection, reseat the cable, and cold-cycle the board. Images built before
the GEM1 PHY reset fix also left active-low `GEM1_RGMII_RESET` on PMC MIO36
unmanaged. Current builds pulse that line during PHY probe before
`systemd-networkd` starts configuring `end0`. Physical validation found the
Marvell 88E1116R at MDIO address 7, negotiated 1 Gbps full-duplex, incremented
both receive and transmit counters, and passed ping in both directions.

### No carrier

Verify that the cable is connected to the intended Huins PS GEM port and the
board-facing lab-host adapter. Reseat the cable and check link LEDs. Do not reset
or reprogram the FPGA for a physical no-carrier condition.

### TCF is inactive

Run on the board:

```bash
systemctl --no-pager --full status tcf-agent.service
journalctl -u tcf-agent.service --no-pager -n 100
sudo systemctl restart tcf-agent.service
```

### Network fails after reboot

Use UART to check the persistent setup:

```bash
cat /etc/systemd/network/10-end0.network
systemctl is-enabled systemd-networkd.service
systemctl is-active systemd-networkd.service
networkctl --no-pager status end0
```

Do not use JTAG `device reset` merely to repair Linux networking. On this board,
a logical JTAG system reset can leave the APU in `FPD domain isolation`; that
state requires complete main-power and USB/JTAG removal before booting again.
