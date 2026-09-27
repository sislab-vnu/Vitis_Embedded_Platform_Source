# Huins VP1902 JTAG and XSDB Guide

This guide explains how to use JTAG, `hw_server`, XSDB/XSCT, and the CP210 UART
to control the Huins MFP-VP1902-S board, test its SD card, and recover an EDF
installation after a failed firmware-to-Linux handoff.

The procedures are written for Vivado and Vitis 2025.2 on the
`2025.2-sislab` branch. They avoid site-specific IP addresses, credentials, and
temporary lab scripts.

Use `xsdb` for interactive debug sessions and small inspection scripts. The
checked-in recovery loader uses `xsct`, which provides the same target and
device-control commands while retaining the Vitis scripting environment.

## What is validated

| Procedure | Status |
|---|---|
| Connect to the VP1902 through `hw_server` | Validated |
| Program a complete `BOOT.BIN` through JTAG | Validated |
| Boot a matched kernel and DT with explicit `booti` payloads | Validated |
| Load the checked-in Linux rescue flow | Validated |
| Inspect and recover a powered SD card | Validated |
| Enter EDF with `kexec` after card recovery | Validated |
| Run the linked 4096-element `vadd` test | Validated |
| Clean generic packaged SD boot | Pending board validation |
| Exact SW1 positions on every board revision | Pending physical confirmation |

JTAG programming changes volatile device state. The checked-in rescue loader
does not write the SD card. Commands such as U-Boot `mmc write`, `fatwrite`, or
Linux read/write mounts can modify the card and are intentionally excluded from
the normal diagnostic path.

## Safety rules

1. Confirm the target is `Versal xcvp1902` before resetting or programming it.
2. Keep a known-good copy of the card's ESP before modifying boot files.
3. Mount card partitions read-only until their identity and contents are known.
4. Treat `BOOT.BIN`, the platform DT, host program, and xclbin as one matched
   artifact set.
5. Do not mix EDF and common-image kernels, XRT libraries, or `zocl` modules.
6. Do not use Linux `devmem` on the live SDHCI controller. It previously wedged
   the A72.
7. Stop the A72 before non-destructive XSDB register reads, then resume it when
   inspection is complete.
8. Do not send a second APU-only PDI after the A72 is running. The observed
   result was `XPmApuCore_WakeUp: Status = 7DB`.
9. If a CDO load stalls, do not repeatedly reset and reprogram. Follow the
   complete-power-removal procedure below.
10. A zero command return is not enough for an SD test. Require the expected
    byte count and subsequent card enumeration.

## Board connections

The Huins user guide identifies these controls:

| Item | Purpose |
|---|---|
| `J16` | 12 V DC input, at least 4 A |
| Front-panel `PWR SW` | System power push button |
| Rear ATX PSU rocker | Disconnects the main power source |
| Clock-module `SW6` | Programs the `CLK3` `M[7:0]` divider; not a power switch |
| `D_LED1` | Power indicator |
| `J21` | CP210 USB UART |
| `J22` | Digilent/VCON USB JTAG |
| `J10` | microSD socket |
| `SW1` | Boot-mode selector |

The vendor guide shows the following SW1 values in `4321:MODE` order:

| Mode | SW1[4:1] | Switches shown as ON |
|---|---:|---|
| JTAG | `0000` | None |
| QSPI | `0010` | SW1-2 |
| SD 2.0 | `0101` | SW1-1 and SW1-3 |
| SD 3.0 | `1110` | SW1-2, SW1-3, and SW1-4 |

The platform uses SD 3.0. These values come from page 33 of
`huins_mfp-vp1902_userguide.pdf`; confirm them against the exact board revision
before relying on autonomous SD boot. The exact switch positions used during
the recorded platform validation were not captured.

USB UART and JTAG can back-power part of the board or SD interface. A true cold
reset requires shutting down with the front-panel `PWR SW`, switching off and
unplugging the rear ATX PSU, and disconnecting both USB paths for at least ten
seconds. Do not change clock-module `SW6` as part of a power cycle.

For an autonomous SD-boot trial, power everything down, set SW1 to the vendor's
SD 3.0 position, insert the card, reconnect and switch on the rear ATX PSU, and
press the front-panel `PWR SW`. Attach the host tools only after the complete
power-removal interval; reconnect J21 before pressing `PWR SW` only when capture
of the earliest UART output is required. For a JTAG-controlled trial, use the
vendor's JTAG position and program a complete image as described below. Do not
test QSPI until a separate flash backup and restore procedure has been
established.

## Prepare the host

Source the 2025.2 tools and enter the platform directory:

```bash
source <Vitis_install>/Vitis/2025.2/settings64.sh
cd Xilinx_Official_Platforms/huins_vp1902_base
```

Set the common-image and hardware-server paths:

```bash
export COMMON_SW=<path-to-xilinx-versal-common-v2025.2>
export HW_SERVER_URL=tcp:127.0.0.1:3121

test -f "$COMMON_SW/Image"
test -f "$COMMON_SW/rootfs.tar.gz"
```

Start `hw_server` on the machine connected to J22:

```bash
hw_server -s tcp::3121
```

If JTAG is attached to another Linux host, run `hw_server` there and either use
its reachable address or create an SSH tunnel:

```bash
ssh -L 3121:127.0.0.1:3121 <user>@<jtag-host>
export HW_SERVER_URL=tcp:127.0.0.1:3121
```

Do not expose `hw_server` to an untrusted network. It provides direct control
over the target.

## Connect the UART

Use the CP210 stable device name rather than a changing `/dev/ttyUSBn` number:

```bash
picocom -b 115200 \
  /dev/serial/by-id/usb-Silicon_Labs_CP2102N_USB_to_UART_Bridge_Controller_*-if00-port0
```

The UART route depends on the programmed hardware:

| Hardware image | CP210 route |
|---|---|
| Linked Vitis platform | PS UART1 for U-Boot, Linux earlycon, and the `ttyAMA1` getty |
| Reference recovery `BOOT.BIN` | PS UART1 |

The platform preserves the board's native UART1 route to the physical CP210
connection. Linux keeps `ttyAMA0` as the full kernel console because
`console=ttyAMA1` stopped normal boot during serial-driver handoff. UART1 remains
available for earlycon and for the initramfs or systemd getty shell.

A PL-empty pre-synthesis XSA does not provide a usable EMIO serial route. UART
silence alone is therefore not proof that PLM or Linux failed.

## Discover the JTAG targets

Start XSDB:

```bash
xsdb
```

Connect and list both JTAG and debug targets:

```tcl
connect -url tcp:127.0.0.1:3121
jtag targets
targets
```

Select the whole device before `device reset`, `device program`, or `plm log`:

```tcl
targets -set -filter {name == "Versal xcvp1902"}
```

Select A72 core 0 before processor control or memory inspection:

```tcl
targets -set -filter {name =~ "Cortex-A72 #0"}
```

If either filter returns no target, check J22, board power, `hw_server`, the
network or SSH tunnel, and whether another process owns the cable.

Exit an interactive session with:

```tcl
disconnect
exit
```

## Basic device control

### Reset and program a complete image

Use this sequence for a complete matched `BOOT.BIN`:

```tcl
connect -url tcp:127.0.0.1:3121
targets -set -filter {name == "Versal xcvp1902"}
device reset
after 3000
device program /absolute/path/to/BOOT.BIN
after 5000
plm log
```

Required PLM success evidence is:

```text
Boot PDI Load: Done
```

`device program` is volatile. It does not copy `BOOT.BIN` to the SD card.

In JTAG boot mode, U-Boot tries `bootcmd_jtag` before MMC and sources the memory
at `scriptaddr`. A logical device reset does not clear DDR, so that address can
still contain a script from an earlier run. PLM success and a running Linux
system therefore do not prove that the newly programmed image supplied the
kernel or runtime DT. For deterministic validation, use the checked-in rescue
flow, explicitly download the matching kernel and DT, and invoke `booti` with
the downloaded DT address. Do not infer artifact identity from network reachability
alone.

### Stop and resume the A72

```tcl
targets -set -filter {name =~ "Cortex-A72 #0"}
stop
rrd pc
rrd sp
con
```

Use `stop` only when needed. Leaving a production Linux system halted can cause
network timeouts, watchdog activity, or stalled peripherals.

### Read a physical register safely

Only use a register address verified against the VP1902 register map or a
checked-in diagnostic. Do not guess addresses.

```tcl
targets -set -filter {name =~ "Cortex-A72 #0"}
stop
mrd -address-space PA <verified-physical-address> 1
con
```

Prefer read-only snapshots. Do not use `mwr` on clocks, resets, SDHCI, PMC, or
NoC registers unless a separately reviewed recovery procedure explicitly
requires it.

## Check whether a silent JTAG boot actually succeeded

Do not declare failure from missing UART output alone. Check:

1. Run `plm log` on the `Versal xcvp1902` target.
2. Require `Boot PDI Load: Done` and inspect any `PLM Error Status` line.
3. Run `targets` and inspect the A72 and FPD state.
4. Test the board network if Linux should have started.
5. Test the TCF agent on TCP port 1534 if the image provides it.

Example host checks:

```bash
ping -c 3 <board-ip>
nc -zvw3 <board-ip> 1534
```

If the A72 is already awake, do not send another APU-only image. If it remains
in `FPD domain isolation` and PLM reports `BOOTMODE: 0x0`, the target is waiting
in JTAG mode. Program the complete `BOOT.BIN`, or perform a real power-on reset
after setting the physical boot switches.

## Test the SD card from U-Boot

Interrupt the U-Boot countdown on the CP210 UART and use read-only commands:

```text
mmc list
mmc dev 0
mmc rescan
mmc info
part list mmc 0
fatls mmc 0:1
```

Use a large file read to verify more than card identification. The kernel load
address below is also used by the checked-in rescue flow and does not modify the
card:

```text
fatload mmc 0:1 0x20000000 Image
echo $?
echo $filesize
```

For the validated common-image kernel, require both:

```text
33083904 bytes read
0
```

The exact byte count changes if `Image` changes, so compare against the host
file before testing:

```bash
stat -c '%s' "$COMMON_SW/Image"
sha256sum "$COMMON_SW/Image"
```

The successful U-Boot handoff used 3.3 V at 25 MHz and reported these calibrated
delay values:

```text
ITAP_DELAY=0x00000100
OTAP_DELAY=0x00000040
```

Stop if U-Boot reports:

```text
Card did not respond to voltage select! : -110
```

Do not continue to Linux and call the handoff test successful. Use the rescue
procedure below.

Avoid `mmc write`, `fatwrite`, partitioning, formatting, and environment-save
commands during diagnosis.

## Load the checked-in rescue environment

The loader at `hw/xsa_scripts/jtag_edf_rescue.tcl` performs these actions:

1. Connects to `hw_server`.
2. Resets the VP1902.
3. Programs a reference recovery `BOOT.BIN`.
4. Retries for up to 30 seconds while A72 core 0 leaves FPD isolation, then
   stops it.
5. Loads `Image` at `0x20000000`.
6. Loads the initramfs at `0x30000000`.
7. Loads the Linux DT at `0x1000`.
8. Prints the two commands needed to start Linux, waits two seconds for the
   operator to hold Ctrl-C, and resumes U-Boot.

Prepare the inputs:

```bash
export RECOVERY_BOOT=<path-to-known-good-Huins-reference-BOOT.BIN>
export RESCUE_IMAGE="$COMMON_SW/Image"
export RESCUE_INITRAMFS=<path-to-huins-edf-rescue.cpio.gz>
export RESCUE_DTB="$PWD/sw/build/platform/image/system.dtb"

test -f "$RECOVERY_BOOT"
test -f "$RESCUE_IMAGE"
test -f "$RESCUE_INITRAMFS"
test -f "$RESCUE_DTB"
gzip -t "$RESCUE_INITRAMFS"
```

See [USAGE.md](USAGE.md#1-build-a-small-uart-rescue-initramfs) for the validated
BusyBox initramfs construction commands.

Open the CP210 terminal first and hold Ctrl-C, then run the loader in another
terminal. This interrupts U-Boot as soon as A72-0 resumes and avoids racing its
automatic boot command:

```bash
xsct hw/xsa_scripts/jtag_edf_rescue.tcl \
  "$HW_SERVER_URL" "$RECOVERY_BOOT" "$RESCUE_IMAGE" \
  "$RESCUE_INITRAMFS" "$RESCUE_DTB"
```

At the `Versal>` prompt, enter the commands printed by the loader. They have
this form:

```text
setenv bootargs console=ttyAMA0,115200 earlycon=pl011,mmio32,0xFF010000,115200n8 loglevel=8 ignore_loglevel clk_ignore_unused rdinit=/init cma=512M
booti 0x20000000 0x30000000:0x<calculated-initramfs-size> 0x1000
```

Do not copy an initramfs size from another build. Use the value printed by the
script.

The rescue shell appears as:

```text
~ #
```

## Recover an uninitialized powered card

Use this procedure when U-Boot reports `-110` and rescue Linux still has no
`/dev/mmcblk0`.

1. Leave the board and rescue Linux powered.
2. Eject the microSD card.
3. Firmly reinsert the card.
4. Wait five seconds.
5. Confirm the block device and all three EDF partitions.

At the rescue shell:

```sh
BB=/usr/bin/busybox
$BB sleep 5
$BB ls -l /dev/mmcblk0 /dev/mmcblk0p1 /dev/mmcblk0p2 /dev/mmcblk0p3
$BB cat /sys/kernel/debug/mmc0/ios
$BB blkid /dev/mmcblk0p1 /dev/mmcblk0p2 /dev/mmcblk0p3
```

The recorded EDF card used:

| Partition | Role |
|---|---|
| `/dev/mmcblk0p1` | ESP |
| `/dev/mmcblk0p2` | Storage |
| `/dev/mmcblk0p3` | EDF root |

The rescue-kernel reinsertion test reported 4-bit, 3.3 V, 50 MHz SD
high-speed operation. This is recovery evidence, not the generated platform's
final Linux setting; the final platform deliberately limits Linux to 25 MHz.

## Inspect the card without modifying it

Mount the ESP and root filesystem read-only:

```sh
$BB mkdir -p /efi /rootfs
$BB mount -o ro /dev/mmcblk0p1 /efi
$BB mount -o ro /dev/mmcblk0p3 /rootfs
$BB sha256sum /efi/BOOT.BIN /efi/Image /efi/system.dtb
$BB cat /rootfs/etc/os-release
```

The reference EDF recovery `BOOT.BIN` had this recorded hash:

```text
85adaa59aa54368174b1abe0ef402c82aaf285830d07fe13c77128b7c2446b37  /efi/BOOT.BIN
```

That hash applies only to the reference recovery image. A linked accelerator
package has a different `BOOT.BIN`; compare it with the matching host artifact
rather than the reference hash.

If `/efi/boot.bin.edf-orig` exists, restore it only after verifying that it is a
known-good backup:

```sh
test -s /efi/boot.bin.edf-orig
$BB mount -o remount,rw /efi
$BB cp -a /efi/boot.bin.edf-orig /efi/boot.bin
$BB cmp /efi/boot.bin.edf-orig /efi/boot.bin
$BB sync
$BB mount -o remount,ro /efi
```

If there is no trusted backup, stop. Power off and repair the card from the
development host. Do not guess which `BOOT.BIN` belongs on the card.

## Enter EDF with `kexec`

After powered reinsertion, avoid another firmware reset because it can lose the
working card state. Use the EDF root filesystem's loader and `kexec` binary:

```sh
ROOT_PARTUUID=$($BB blkid -s PARTUUID -o value /dev/mmcblk0p3)
test -n "$ROOT_PARTUUID"
test -x /rootfs/usr/sbin/kexec

EDF_LD=/rootfs/lib/ld-linux-aarch64.so.1
EDF_LIBS=/rootfs/lib:/rootfs/usr/lib
EDF_KEXEC=/rootfs/usr/sbin/kexec

$EDF_LD --library-path "$EDF_LIBS" "$EDF_KEXEC" -l /efi/Image \
  --dtb=/efi/system.dtb \
  --command-line="root=PARTUUID=$ROOT_PARTUUID ro rootwait earlycon uio_pdrv_genirq.of_id=generic-uio"
$BB sync
$EDF_LD --library-path "$EDF_LIBS" "$EDF_KEXEC" -e
```

Always derive the PARTUUID from the current card. Do not copy the UUID from a
different SD image.

The validated recovery reached EDF 26.06 with kernel
`6.18.10-xilinx-g4f7afe14f724`, mounted p3 as root, and brought up GEM interface
`end0`.

## Verify Linux after recovery

Use the UART, SSH, or the image's TCF agent to collect:

```bash
uname -a
cat /etc/os-release
cat /proc/cmdline
findmnt -no SOURCE,FSTYPE,OPTIONS /
lsblk -o NAME,FSTYPE,LABEL,PARTUUID,MOUNTPOINTS
ip -4 -br addr
dmesg | grep -E 'mmc|sdhci|error -110|error -84'
```

For the final generated Linux handoff, require:

```text
mmcblk0: mmc0:aaaa SC64G 59.5 GiB
mmcblk0: p1 p2 p3
```

The generated runtime DT intentionally uses:

```dts
no-1-8-v;
max-frequency = <25000000>;
clk-phase-sd-hs = <0>, <0>;
```

Treat `error -110`, `error -84`, CID CRC errors, or missing partitions as a
failed handoff.

## Test the linked accelerator

First verify that Linux is running the matching linked PDI and platform DT.
Then check EDF's own XRT stack:

```bash
sudo modprobe zocl
test -e /sys/bus/platform/devices/zyxclmm_drm
test -e /dev/dri/renderD128
xrt-smi examine
```

`xrt-smi examine` must report one ready edge device. EDF may print
`IRQ index 32 not found` during initial `zocl` probing; that warning alone was
non-fatal in the validated run.

Run the checked-in 4096-element example:

```bash
cd /home/amd-edf/vp1902-vadd
./simple_vadd vadd.xclbin
status=$?
printf 'exit status: %s\n' "$status"
```

Required output is:

```text
Mismatches: 0/4096
TEST PASSED
exit status: 0
```

An asynchronous SError in `xrt_cu_hls_init()` indicates that the compute-unit
address in the xclbin is not reachable in the active hardware. Verify that the
linked `BOOT.BIN`, DT, and xclbin came from the same current package. Do not use
the superseded September 1 linked artifact.

The pre-PHY-reset UART1 package had these recorded SHA-256 values. Keep this
table only for reproducing that historical SD/UART validation; it is not the
corrected GEM1 reset artifact set.

| Artifact | SHA-256 |
|---|---|
| Linked `BOOT.BIN` | `46b66ec59cff67a1f7afbe843ed9fa5b4a4c45c6145c6dd0bd8efaa081531abb` |
| Linux `system.dtb` | `82c0b40ee47e82adbaf9f26e4d903c594a2a21d7d6bdaf17e2d073c0abe9f461` |
| Common-image `Image` | `79359c3f0af65cef3dbabab725b156a4b7b1925f781ab42f2f997be70f6dc86c` |
| Packaged `vadd.xclbin` | `1ee7e2d0167195d7b7214209bf604082faaea6cab42f01635a1ac18841435dbc` |
| `simple_vadd` host | `00b461ecde580d7cfd0a07b71b780c8b59fea4640cdaa3d9b6690ef3be498a33` |

The corrected GEM1 reset physical validation used:

| Artifact | SHA-256 |
|---|---|
| Fully linked PDI | `6b317de3ffc77318d31602945f87b2c560e3975c813e9e35be67580b3dd4a69c` |
| JTAG boot container | `041ff67e6498d6eadf387a87fd3e7a27b32eb77a55a36964b3955cc228d9eaf4` |
| Linux `system.dtb` | `436268f9e5d7ca839f0d7ff707b30d09032183d5a1d63c83e8b7e714a1ef9d8e` |
| Matching EDF `Image` | `74979cce50398475713fbca8301cbc0a8dc35e64af4e8d6e55e31f73b323ca59` |
| Packaged `vadd.xclbin` | `7c5f42a4b1d9086a2e31da92c3dfa5b07f2ee3f8cdbf4b713ea3286a9b9618ad` |
| `simple_vadd` host | `00b461ecde580d7cfd0a07b71b780c8b59fea4640cdaa3d9b6690ef3be498a33` |

The JTAG container loaded the complete PDI successfully, but deterministic
Linux validation required explicit kernel and DT downloads followed by
`booti`; see the `scriptaddr` warning above.

Hash the actual files before deployment. A matching filename is not sufficient
evidence.

## Recovery decision table

| Symptom | Action |
|---|---|
| No JTAG targets | Check J22, power, `hw_server`, tunnel, and cable ownership |
| No UART after programming | Check `plm log`, A72/FPD state, network, and TCF before declaring failure |
| `Boot PDI Load: Done` absent | Inspect the first PLM error and stop the test |
| A72 in `FPD domain isolation` with `BOOTMODE: 0x0` | Program the complete JTAG image or perform a true power-on reset after selecting the boot mode |
| `device program` stalls on a CDO | Remove all board and USB/JTAG power, wait, restore power, and retry once |
| U-Boot reports SD `-110` | Load rescue Linux, then eject and reinsert the powered card |
| Rescue Linux has no `mmcblk0` | Reinsert the card while rescue Linux remains powered |
| ESP hash differs and no trusted backup exists | Stop and repair the card from the development host |
| Linux reports `error -110`, `error -84`, or CID CRC errors | Verify 3.3 V, 25 MHz, zero-phase runtime DT and repeat from a true cold state |
| `modprobe zocl` reports invalid module format | Stop mixing kernel/module builds; use the image's matching stack |
| `xrt-smi` reports zero devices | Verify linked PDI, platform DT, `zocl`, and `/dev/dri/renderD128` |
| `IRQ index 32 not found` only | Continue validation; require a render node, ready device, and successful CU run |
| A72 SError in `xrt_cu_hls_init()` | Replace the mismatched PDI/DT/xclbin set |
| Live register inspection is needed | Stop A72 and use read-only XSDB `mrd`; never use Linux `devmem` |

## Recover from a PLM or CDO stall

Use complete power removal when any of these are true:

- `device program` stops making progress on a CDO partition.
- Repeated `device reset` calls leave the same PLM error.
- The A72 or FPD remains isolated after loading a known-good image.
- The SD card does not reset because USB/JTAG is back-powering the board.

Procedure:

1. Stop XSDB commands and close UART programs that own the cable.
2. Press the front-panel `PWR SW` to shut down the system.
3. Switch off the rear ATX PSU rocker and unplug its AC input.
4. Disconnect J21 and J22. Do not operate clock-module `SW6`.
5. Wait at least ten seconds.
6. Leave the SD card inserted unless the recovery procedure explicitly calls
   for powered reinsertion later.
7. Reconnect the ATX input, switch on its rear rocker, and press the front-panel
   `PWR SW`.
8. Reconnect UART and JTAG.
9. Start `hw_server` and reconnect XSDB.
10. Retry one known-good complete `BOOT.BIN`.
11. Check `plm log` before taking another action.

A logical reset did not clear the observed stale PMC/CDO state.

## Useful XSDB script template

For repeatable diagnostics, put commands in a Tcl file rather than entering
them manually:

```tcl
if {$argc != 1} {
  puts "Usage: xsdb inspect_vp1902.tcl <hw-server-url>"
  exit 1
}

connect -url [lindex $argv 0]
targets -set -filter {name == "Versal xcvp1902"}
plm log
targets
exit
```

Run it with:

```bash
xsdb inspect_vp1902.tcl "$HW_SERVER_URL" | tee inspect_vp1902.log
```

Keep write operations out of general inspection scripts. A reset or program
operation should be explicit in the script name and invocation.

## Related documentation

- [README.md](README.md): architecture and validation summary.
- [USAGE.md](USAGE.md): complete build, package, EDF deployment, and rescue
  initramfs commands.
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md): complete problem/solution record,
  failed experiments, and final artifact hashes.
- `hw/xsa_scripts/jtag_edf_rescue.tcl`: checked-in XSCT rescue loader.
- `sw/prebuilt_linux/user_dts/system-user-uboot.dtsi`: U-Boot SD control DT.
- `sw/prebuilt_linux/user_dts/system-user.dtsi`: Linux SD runtime DT.
