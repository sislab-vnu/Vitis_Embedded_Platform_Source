# Huins VP1902 Platform Usage

This guide builds `huins_vp1902_base_202520_1`, links the Vitis 2025.2
`vadd` sample, packages a Linux SD-card image, and runs the accelerator on the
Huins MFP-VP1902-S board.

The platform and `vadd` hardware path have been validated on the physical
board. The generic common-image SD packaging commands below follow the standard
Vitis Versal flow, but boot-mode switch settings and a clean image written by
that exact packaging path still require final board validation. Keep working
boot media available while testing it.

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for symptoms, root causes,
confirmed fixes, rejected experiments, and remaining limitations from the
platform bring-up. See [JTAG_XSDB_GUIDE.md](JTAG_XSDB_GUIDE.md) for JTAG target
control, SD diagnostics, and the recovery decision tree.

## Prerequisites

- A Linux host with Vivado and Vitis 2025.2 installed and licensed.
- The `xilinx-versal-common-v2025.2` common image from the AMD Embedded
  Development downloads page. Its directory must contain `Image`,
  `rootfs.ext4`, `sdk.sh`, `boot.scr`, `bl31.elf`, and `u-boot.elf`.
- The Huins MFP-VP1902-S board, a microSD card, and access to the onboard CP210
  USB-to-UART bridge.
- Enough local storage and time for Vivado implementation. Both the platform
  hardware build and the `v++` hardware link are substantial builds.

The commands assume this repository is already checked out on the
`2025.2-sislab` branch. Set the paths for the local installation:

```bash
source <Vitis_install>/Vitis/2025.2/settings64.sh

cd Xilinx_Official_Platforms/huins_vp1902_base
export PLATFORM_ROOT="$PWD"
export COMMON_SW=/path/to/xilinx-versal-common-v2025.2
export PLATFORM_ROOTFS="$PLATFORM_ROOT/sw/build/platform/rootfs/rootfs.ext4"

test -f "$COMMON_SW/Image"
test -f "$COMMON_SW/rootfs.ext4"
test -f "$COMMON_SW/sdk.sh"
```

`make linux` creates `PLATFORM_ROOTFS` from the common-image root filesystem,
installs the platform's `10-end0.network`, and enables the custom UART1 getty.
GEM requests DHCP with route metric 100 while retaining `192.168.1.57/24` and
gateway `192.168.1.1` at metric 2048 as the deterministic fallback. The input
common image remains unchanged.

The internal Vitis 2025.2 platform suffix is `202520_1`, not `202520_2`.

## Platform Features

| Feature | Platform exposure |
|---|---|
| Device | Versal Premium Gen1 `xcvp1902-vsva6865-2MP-e-S` |
| Linux processor | Cortex-A72, XRT runtime domain |
| PS DDR | Two 32 GiB DDR4 SODIMMs through two DDRMCs; 64 GiB physical-memory validation completed |
| Kernel memory ports | Four NoC slave interfaces, `S06_AXI` through `S09_AXI`, tagged `DDR` |
| Kernel control | Expandable AXI-Lite control path, `M01_AXI` through `M15_AXI` |
| Kernel interrupts | 32 interrupts through AXI INTC to the PS |
| Kernel clocks | 100, 200, 300, 400, and 600 MHz; 100 MHz is the default |
| Board I/O | SD1, dual-parallel QSPI, USB 2.0 ULPI, GEM1 RGMII, EMIO MDIO, UART0/1, and I2C0/1 |
| Linux artifacts | Generated system DTB plus Versal common-image kernel, root filesystem, TF-A, and U-Boot |
| Default access | UART1 U-Boot, earlycon, and getty at 115200; GEM DHCP with `192.168.1.57/24` static fallback |
| AI Engine | Not available on Versal Premium Gen1 |
| PL DDR SODIMM | Not exposed by this base platform |
| Hardware emulation | Not supported for this part in Vitis 2025.2 because the `ps_wizard` TLM model is unavailable |

UART1 uses the board's native CP210 pair at `BK13`/`BL14` for U-Boot, Linux
earlycon, and the userspace getty at 115200 baud. The stable Linux kernel
console is `ttyAMA0` on `BK17`/`BL18`. Both UARTs, I2C, and GEM1 MDIO use
LVCMOS18 in HDIO bank 408.

Because the console uses EMIO, a pre-synthesis base platform has no usable
serial path by itself. The path becomes active when `v++ -l` creates the linked
PL design, or when the optional post-implementation base PDI is booted.

## Build the Platform

### Standard extensible platform

The default build creates the pre-synthesis extensible XSA intended for Vitis
application linking, generates the Linux device tree, copies the common-image
boot files, and exports the platform:

```bash
make all PREBUILT_LINUX_PATH="$COMMON_SW"
```

The same flow can be run in stages:

```bash
make xsa
make linux PREBUILT_LINUX_PATH="$COMMON_SW"
make platform PREBUILT_LINUX_PATH="$COMMON_SW"
```

The principal outputs are:

| Output | Path |
|---|---|
| Hardware XSA | `hw/build/hw.xsa` |
| U-Boot control DTB | `sw/build/platform/boot/u-boot.dtb` |
| Linux runtime DTB | `sw/build/platform/image/system.dtb` |
| Platform files | `platform_repo/huins_vp1902_base_202520_1/export/huins_vp1902_base_202520_1/` |
| Platform definition | `platform_repo/huins_vp1902_base_202520_1/export/huins_vp1902_base_202520_1/huins_vp1902_base_202520_1.xpfm` |

Set and inspect the exported platform:

```bash
export XPFM="$PLATFORM_ROOT/platform_repo/huins_vp1902_base_202520_1/export/huins_vp1902_base_202520_1/huins_vp1902_base_202520_1.xpfm"

test -f "$XPFM"
platforminfo -p "$XPFM"
```

`platforminfo` must report the `xcvp1902` device, an extensible hardware target,
the `xrt` Cortex-A72 software domain, and the five kernel clocks listed above.

The exported `sw/boot/linux.bif` loads `boot/u-boot.dtb`. Vitis also places the
Linux runtime tree at `sw/boot/system.dtb` and `sw/xrt/image/system.dtb`; neither
of those files is the U-Boot control tree.

### Build the SD handoff fix

The platform can use a site-built U-Boot through `UBOOT_ELF`. Build the exact
tested revision and apply the included early host-reset patch:

```bash
export UBOOT_SRC="$HOME/src/u-boot-xlnx"
export UBOOT_BUILD="$HOME/build/u-boot-xlnx-vp1902"

git clone https://github.com/Xilinx/u-boot-xlnx.git "$UBOOT_SRC"
git -C "$UBOOT_SRC" checkout 5e0d8abc7e092b62a5de17aa7aadfad7af5f0f59
git -C "$UBOOT_SRC" apply \
  "$PLATFORM_ROOT/sw/prebuilt_linux/patches/0001-mmc-zynq_sdhci-reset-the-host-controller.patch"

make -C "$UBOOT_SRC" O="$UBOOT_BUILD" xilinx_versal_virt_defconfig
make -C "$UBOOT_SRC" O="$UBOOT_BUILD" \
  CROSS_COMPILE=aarch64-linux-gnu- -j"$(nproc)"
export UBOOT_ELF="$UBOOT_BUILD/u-boot.elf"
```

Generate the platform with the patched U-Boot:

```bash
make all PREBUILT_LINUX_PATH="$COMMON_SW" UBOOT_ELF="$UBOOT_ELF"
```

Use the unmodified `Image` from the Vitis 2025.2 common image. The generated
Linux runtime DT supplies the SDIO1 reset and the validated handoff settings:

```dts
no-1-8-v;
max-frequency = <25000000>;
clk-phase-sd-hs = <0>, <0>;
```

These keep Linux in the same 3.3 V, 25 MHz electrical state that U-Boot uses.

If Vitis reports that an older generated platform component already exists,
remove only that generated component and retry packaging:

```bash
rm -rf "$PLATFORM_ROOT/platform_repo/huins_vp1902_base_202520_1"
make platform PREBUILT_LINUX_PATH="$COMMON_SW"
```

After changing a hardware Tcl or XDC source, clean the generated Vivado output
and the generated platform component before rebuilding:

```bash
make clean
make all PREBUILT_LINUX_PATH="$COMMON_SW"
```

### Optional post-implementation base

Use this path to validate the base design itself or to produce a fixed base PDI
with the EMIO console routed. It is not required for the `vadd` flow because
`v++ -l` implements the complete application design.

```bash
make clean
make all PRE_SYNTH=FALSE PREBUILT_LINUX_PATH="$COMMON_SW"
```

This produces `hw/build/hw.pdi` beside `hw/build/hw.xsa`. To create a standalone
base `BOOT.BIN` from that PDI:

```bash
make -C sw/prebuilt_linux bootimage \
  XSA="$PLATFORM_ROOT/hw/build/hw.xsa" \
  PREBUILT_LINUX_PATH="$COMMON_SW"
```

The result is `sw/build/platform/boot/BOOT.BIN`. This image represents the
implemented base design without an application kernel.

If this optional build replaced the standard platform and the next step is an
application link, recreate the pre-synthesis platform first:

```bash
make clean
make all PREBUILT_LINUX_PATH="$COMMON_SW"
```

## Build the `vadd` Example

The kernel comes from the Vitis 2025.2 installation. The repository provides a
small native-XRT host program in `examples/vadd/host.cpp`.

Start in a shell with the Vitis environment sourced and `PLATFORM_ROOT`,
`COMMON_SW`, and `XPFM` set as above:

```bash
export VADD_SRC="$XILINX_VITIS/samples/vadd/src"
mkdir -p "$PLATFORM_ROOT/app/vadd"
cd "$PLATFORM_ROOT/app/vadd"

v++ -c -t hw --platform "$XPFM" -k vadd \
  -I"$VADD_SRC" \
  -o vadd.xo "$VADD_SRC/vadd.cpp"

v++ -l -t hw --platform "$XPFM" \
  -o vadd.link.xsa vadd.xo
```

For this Versal platform the link output must have the `.xsa` extension. The
link runs Vivado implementation and embeds the linked PDI and runtime metadata
in `vadd.link.xsa`. The validated design uses one `vadd` compute unit, a 100 MHz
kernel clock, `S06_AXI` and `S07_AXI` DDR connections, and one interrupt.

### Cross-compile the host

Install the common-image SDK once. Select any persistent destination that is
outside the repository:

```bash
export SDK_DIR="$HOME/xilinx-versal-common-v2025.2-sdk"
"$COMMON_SW/sdk.sh" -y -d "$SDK_DIR"
```

Source the generated environment file and compile the checked-in host:

```bash
source "$SDK_DIR/environment-setup-cortexa72-cortexa53-amd-linux"

$CXX -std=c++17 -O2 \
  "$PLATFORM_ROOT/examples/vadd/host.cpp" \
  -o "$PLATFORM_ROOT/app/vadd/simple_vadd" \
  -lxrt_coreutil -luuid -pthread

file "$PLATFORM_ROOT/app/vadd/simple_vadd"
```

`file` must identify `simple_vadd` as an AArch64 ELF binary. Use a fresh shell
with the Vitis settings sourced for the packaging step, because the Yocto SDK
environment changes compiler and sysroot variables.

## Package an SD Image

In a fresh Vitis shell, restore the variables and package the fixed linked XSA:

```bash
source <Vitis_install>/Vitis/2025.2/settings64.sh
cd Xilinx_Official_Platforms/huins_vp1902_base
export PLATFORM_ROOT="$PWD"
export COMMON_SW=/path/to/xilinx-versal-common-v2025.2
export KERNEL_IMAGE="${KERNEL_IMAGE:-$COMMON_SW/Image}"
export XPFM="$PLATFORM_ROOT/platform_repo/huins_vp1902_base_202520_1/export/huins_vp1902_base_202520_1/huins_vp1902_base_202520_1.xpfm"

cd "$PLATFORM_ROOT/app/vadd"
mkdir -p package.hw

v++ -p -t hw --platform "$XPFM" \
  --package.boot_mode sd \
  --package.out_dir package.hw \
  --package.rootfs "$PLATFORM_ROOTFS" \
  --package.kernel_image "$KERNEL_IMAGE" \
  --package.sd_file simple_vadd \
  -o package.hw/vadd.xclbin vadd.link.xsa
```

The important outputs are:

- `package.hw/sd_card.img`: complete partitioned SD-card image.
- `package.hw/BOOT.BIN`: Versal boot image containing the linked design.
- `package.hw/vadd.xclbin`: accelerator binary loaded by XRT.
- `package.hw/sd_card/`: files placed on the SD boot partition.

## Run with an AMD EDF Image

This EDF integration strategy has been physically validated on the Huins board.
It keeps the AMD EDF kernel, root filesystem, and XRT installation, but boots
the linked platform PDI and the device tree generated by this repository.

The validated card reported:

| Component | Validated version |
|---|---|
| Distribution | AMD Embedded Development Framework `26.06+release-S06092318` (`scarthgap`) |
| Kernel | `6.18.10-xilinx` |
| XRT and `zocl` | 2.23.0 |
| EDF partitions | p1 `esp`, p2 `storage`, p3 `root` |
| Visible memory | 64194 MB |

The original successful run used a 2025.2 SDK host named `vadd-test` and a
predecessor linked artifact named `vadd-sd-power.xclbin`. Their recorded SHA-256
hashes were `b932ca98f41b9f17b91184734950820098b2a51263e38741e923ce6c1da9d180`
and `a7fe1de6372c2580e23db2c771dbc7db174b927b94a179f6e0dacc0fdf906bf0`.
That run recorded `TEST PASSED` and exit status zero. The checked-in host
implements a 4096-element native-XRT test. A repeat with the freshly packaged
host and xclbin recorded `Mismatches: 0/4096`, `TEST PASSED`, and exit status
zero. Their SHA-256 hashes were
`00b461ecde580d7cfd0a07b71b780c8b59fea4640cdaa3d9b6690ef3be498a33` and
`1ee7e2d0167195d7b7214209bf604082faaea6cab42f01635a1ac18841435dbc`.

Do not copy XRT libraries or kernel modules from the Vitis 2025.2 common image
onto EDF. The original 2025.2 SDK host ran against EDF's system XRT 2.23, and
EDF's matching `zocl` module was used unchanged. Confirm `uname -a`,
`/etc/os-release`, and `xrt-smi examine` when using another EDF build.

### 0. Verify the starting EDF card

This repository does not distribute the AMD EDF image. Start with a Huins/site
provided EDF card or obtain and flash the image using the provider's procedure.
Boot the unmodified card once and record its baseline:

```bash
uname -a
cat /etc/os-release
xrt-smi examine
lsblk -o NAME,FSTYPE,LABEL,PARTUUID,MOUNTPOINTS
```

The procedure below assumes the three-partition layout shown in the table and
the EDF EFI loader files described below. Stop if the image uses another layout.
Power the board off cleanly after this check. Preserve the board's known-working
EDF SD-boot SW1 setting; the exact switch positions are board-revision-specific
and were not recorded during validation.

### 1. Create the EDF deployment files

First complete the platform build, `vadd` link, and host cross-compilation
sections above. In a fresh shell, source Vitis and restore the path variables:

```bash
source <Vitis_install>/Vitis/2025.2/settings64.sh
cd Xilinx_Official_Platforms/huins_vp1902_base
export PLATFORM_ROOT="$PWD"
export COMMON_SW=/path/to/xilinx-versal-common-v2025.2
export XPFM="$PLATFORM_ROOT/platform_repo/huins_vp1902_base_202520_1/export/huins_vp1902_base_202520_1/huins_vp1902_base_202520_1.xpfm"
export PLATFORM_EXPORT="${XPFM%/*}"
export PLATFORM_DTB="$PLATFORM_EXPORT/sw/boot/system.dtb"

cd "$PLATFORM_ROOT/app/vadd"
```

Package the linked XSA without creating another full SD-card image:

```bash
set -e
rm -rf package.edf
mkdir -p package.edf

v++ -p -t hw --platform "$XPFM" \
  --package.boot_mode sd \
  --package.no_image \
  --package.out_dir package.edf \
  --package.rootfs "$PLATFORM_ROOTFS" \
  --package.kernel_image "$COMMON_SW/Image" \
  --package.sd_file simple_vadd \
  -o package.edf/vadd.xclbin vadd.link.xsa

test -f package.edf/BOOT.BIN
test -f package.edf/vadd.xclbin
test -f "$PLATFORM_DTB"
```

`package.edf/BOOT.BIN` contains the linked PDI, platform DTB, TF-A, and U-Boot.
The EDF kernel and root filesystem are not included and remain on the existing
EDF card.

### 2. Install the files on the EDF card

Power off the board and attach its microSD card to the development host. Find
the three EDF partitions by label before setting these variables:

```bash
lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTUUID,MOUNTPOINTS

export EDF_ESP=/dev/sdX1
export EDF_STORAGE=/dev/sdX2
export EDF_ROOT=/dev/sdX3
export ESP_MNT=/mnt/huins-edf-esp
export ROOT_MNT=/mnt/huins-edf-root
```

Replace `/dev/sdX1`, `/dev/sdX2`, and `/dev/sdX3` with the partitions labelled
`esp`, `storage`, and `root`. Selecting the wrong device can damage the host.
The storage partition does not need to be mounted for this procedure.

Validate the selected devices before mounting anything:

```bash
set -e
test -b "$EDF_ESP"
test -b "$EDF_STORAGE"
test -b "$EDF_ROOT"
test "$(lsblk -ndo LABEL "$EDF_ESP")" = "esp"
test "$(lsblk -ndo LABEL "$EDF_STORAGE")" = "storage"
test "$(lsblk -ndo LABEL "$EDF_ROOT")" = "root"

ESP_PARENT=$(lsblk -ndo PKNAME "$EDF_ESP")
test "$ESP_PARENT" = "$(lsblk -ndo PKNAME "$EDF_STORAGE")"
test "$ESP_PARENT" = "$(lsblk -ndo PKNAME "$EDF_ROOT")"
```

Mount the EFI and root partitions and obtain this card's root PARTUUID:

```bash
set -e
sudo mkdir -p "$ESP_MNT" "$ROOT_MNT"
sudo mount "$EDF_ESP" "$ESP_MNT"
sudo mount "$EDF_ROOT" "$ROOT_MNT"

mountpoint -q "$ESP_MNT"
mountpoint -q "$ROOT_MNT"
ROOT_PARTUUID=$(lsblk -no PARTUUID "$EDF_ROOT")
test -n "$ROOT_PARTUUID"
test -s "$ESP_MNT/boot.bin"
test -f "$ESP_MNT/Image"
test -d "$ESP_MNT/loader/entries"
```

Back up the original EDF boot image before replacing it. A pre-existing backup
causes this from-scratch procedure to stop so that an older backup cannot be
mistaken for the current EDF image:

```bash
set -e
test ! -e "$ESP_MNT/boot.bin.edf-orig"
sudo cp -a "$ESP_MNT/boot.bin" "$ESP_MNT/boot.bin.edf-orig"
test -s "$ESP_MNT/boot.bin.edf-orig"
cmp "$ESP_MNT/boot.bin" "$ESP_MNT/boot.bin.edf-orig"

sudo cp package.edf/BOOT.BIN "$ESP_MNT/boot.bin"
sudo cp "$PLATFORM_DTB" \
  "$ESP_MNT/vp1902-vadd-system.dtb"
cmp package.edf/BOOT.BIN "$ESP_MNT/boot.bin"
cmp "$PLATFORM_DTB" "$ESP_MNT/vp1902-vadd-system.dtb"
```

Add a separate systemd-boot entry. The `options` line deliberately overrides
the common-image root device embedded in the platform DTB with the EDF root
partition:

```bash
set -e
sudo tee "$ESP_MNT/loader/entries/edf-vp1902-vadd.conf" >/dev/null <<EOF
sort-key 15-edf-vp1902-vadd
title EDF Linux - Huins VP1902 Vitis vadd
efi /Image
devicetree /vp1902-vadd-system.dtb
options root=PARTUUID=$ROOT_PARTUUID ro rootwait earlycon=pl011,mmio32,0xFF010000,115200n8 console=ttyAMA0,115200 uio_pdrv_genirq.of_id=generic-uio cma=512M
EOF
```

The explicit earlycon argument selects the board's native UART1 CP210 path.
Linux keeps `ttyAMA0` as its full kernel console because `console=ttyAMA1`
stopped normal boot during serial-driver handoff. The custom getty installed
below provides the login prompt on UART1. The previous UART0 pin remap produced
a silent console in the final linked PDI.

The new entry can be selected manually in the boot menu. To reproduce the
unattended boot selection, make it the persistent test default while retaining
the original loader configuration:

```bash
set -e
test ! -e "$ESP_MNT/loader/loader.conf.edf-orig"
sudo cp -a "$ESP_MNT/loader/loader.conf" \
  "$ESP_MNT/loader/loader.conf.edf-orig"
cmp "$ESP_MNT/loader/loader.conf" \
  "$ESP_MNT/loader/loader.conf.edf-orig"

sudo tee "$ESP_MNT/loader/loader.conf" >/dev/null <<EOF
default edf-vp1902-vadd.conf
timeout 5
EOF
```

This default remains active until restored below. EDF marks `loader.conf` as an
auto-generated file, so an EDF boot-configuration package update may overwrite
the test setting.

Install the accelerator and host in the EDF user's home directory:

```bash
set -e
sudo install -d "$ROOT_MNT/home/amd-edf/vp1902-vadd"
sudo install -m 0755 simple_vadd \
  "$ROOT_MNT/home/amd-edf/vp1902-vadd/simple_vadd"
sudo install -m 0644 package.edf/vadd.xclbin \
  "$ROOT_MNT/home/amd-edf/vp1902-vadd/vadd.xclbin"
sudo install -D -m 0644 \
  "$PLATFORM_ROOT/sw/prebuilt_linux/rootfs_overlay/etc/systemd/network/10-end0.network" \
  "$ROOT_MNT/etc/systemd/network/10-end0.network"
sudo install -D -m 0644 \
  "$PLATFORM_ROOT/sw/prebuilt_linux/rootfs_overlay/etc/systemd/system/huins-uart-getty.service" \
  "$ROOT_MNT/etc/systemd/system/huins-uart-getty.service"
sudo mkdir -p "$ROOT_MNT/etc/systemd/system/getty.target.wants"
sudo rm -f \
  "$ROOT_MNT/etc/systemd/system/getty.target.wants/serial-getty@ttyAMA1.service"
sudo ln -sfn /etc/systemd/system/huins-uart-getty.service \
  "$ROOT_MNT/etc/systemd/system/getty.target.wants/huins-uart-getty.service"
sudo chown -R --reference="$ROOT_MNT/home/amd-edf" \
  "$ROOT_MNT/home/amd-edf/vp1902-vadd"

sync
sudo umount "$ROOT_MNT"
sudo umount "$ESP_MNT"
```

If any command fails after mounting the card, do not continue with the next
block. Restore any files already replaced, then unmount both filesystems:

```bash
if mountpoint -q "$ESP_MNT"; then
  if [ -s "$ESP_MNT/boot.bin.edf-orig" ]; then
    sudo cp -a "$ESP_MNT/boot.bin.edf-orig" "$ESP_MNT/boot.bin"
  fi
  if [ -s "$ESP_MNT/loader/loader.conf.edf-orig" ]; then
    sudo cp -a "$ESP_MNT/loader/loader.conf.edf-orig" \
      "$ESP_MNT/loader/loader.conf"
  fi
  sudo rm -f "$ESP_MNT/loader/entries/edf-vp1902-vadd.conf"
  sudo rm -f "$ESP_MNT/vp1902-vadd-system.dtb"
fi
sync
mountpoint -q "$ROOT_MNT" && sudo umount "$ROOT_MNT"
mountpoint -q "$ESP_MNT" && sudo umount "$ESP_MNT"
```

This does not change EDF's kernel, root filesystem packages, XRT libraries, or
`zocl` module. It replaces the first-stage `boot.bin`, adds one DTB and one
boot-menu entry, optionally selects that entry in `loader.conf`, installs the
two application files, configures networking, and enables the UART1 getty.

### 3. Boot and run `vadd`

Return the card to the board, connect the CP210 UART at 115200 baud, and boot in
SD mode:

```bash
picocom -b 115200 /dev/serial/by-id/usb-Silicon_Labs_CP2102N_USB_to_UART_Bridge_Controller_*-if00-port0
```

Select `EDF Linux - Huins VP1902 Vitis vadd` in the EDF boot menu, or wait for
the persistent five-second test default. The linked PDI activates the EMIO UART1
route to the CP210 pair. UART1 carries U-Boot and Linux earlycon output; after
Linux initializes its serial drivers, `huins-uart-getty.service` supplies the
`ttyAMA1` login prompt. A gap in kernel messages during that handoff is expected.

After logging in as the EDF user, verify that the custom DTB and EDF XRT stack
are active:

```bash
cat /proc/cmdline
free -h
sudo modprobe zocl
test -e /sys/bus/platform/devices/zyxclmm_drm
test -e /dev/dri/renderD128
xrt-smi examine
```

`xrt-smi examine` should show one ready edge device. On the validated EDF 26.06
image it reported XRT 2.23.0, `zocl` 2.23.0, two A72 cores, and about 64 GB of
memory.

Run the example:

```bash
cd /home/amd-edf/vp1902-vadd
./simple_vadd vadd.xclbin
```

Expected output:

```text
Mismatches: 0/4096
TEST PASSED
```

Both the original validated pair and the freshly packaged pair loaded the
xclbin successfully, allocated buffers through CMA, registered the compute-unit
interrupt, and recorded `TEST PASSED` with exit status zero. The latter pass
confirms the current source and packaging output on the board.
The automated rerun used EDF's root-owned TCF agent to launch the deployed
`/storage/simple_vadd /storage/vadd.xclbin` pair and captured the same result.
The host's `device.load_xclbin()` call loads the accelerator; do not run
`fpgautil` separately.
The EDF kernel may print `IRQ index 32 not found` while `zocl` initially probes;
this warning was non-fatal in the validated run. The xclbin subsequently loaded
and the compute-unit interrupt was registered.

### 4. Restore the original EDF boot

If the test image does not boot, power off and mount the EFI partition on the
host again. Restore the original boot image and remove the additional entry:

```bash
set -e
export EDF_ESP=/dev/sdX1
export ESP_MNT=/mnt/huins-edf-esp
sudo mkdir -p "$ESP_MNT"
sudo mount "$EDF_ESP" "$ESP_MNT"
mountpoint -q "$ESP_MNT"
test "$(lsblk -ndo LABEL "$EDF_ESP")" = "esp"
test -s "$ESP_MNT/boot.bin.edf-orig"
sudo cp -a "$ESP_MNT/boot.bin.edf-orig" "$ESP_MNT/boot.bin"
cmp "$ESP_MNT/boot.bin.edf-orig" "$ESP_MNT/boot.bin"
sudo rm -f "$ESP_MNT/loader/entries/edf-vp1902-vadd.conf"
sudo rm -f "$ESP_MNT/vp1902-vadd-system.dtb"
if [ -f "$ESP_MNT/loader/loader.conf.edf-orig" ]; then
  sudo cp -a "$ESP_MNT/loader/loader.conf.edf-orig" \
    "$ESP_MNT/loader/loader.conf"
  cmp "$ESP_MNT/loader/loader.conf.edf-orig" \
    "$ESP_MNT/loader/loader.conf"
fi
sudo rm -f "$ESP_MNT/boot.bin.edf-orig"
sudo rm -f "$ESP_MNT/loader/loader.conf.edf-orig"
sync
sudo umount "$ESP_MNT"
```

This restores the ESP boot files only. The application, network configuration,
and UART getty installed in the EDF root filesystem remain until removed or
restored separately.

## Recover an EDF Boot through JTAG

See [JTAG_XSDB_GUIDE.md](JTAG_XSDB_GUIDE.md) for connection safety, target
discovery, PLM diagnostics, A72 inspection, and the complete recovery decision
tree. This section retains the detailed rescue-initramfs construction commands.

The physical-board validation encountered this recoverable SD initialization
failure after PLM had loaded `BOOT.BIN` successfully:

```text
Versal> mmc dev 0
Card did not respond to voltage select! : -110
```

The SDHCI present-state register still reported the card inserted, but both
U-Boot and Linux left the card uninitialized. A software controller reset,
SDHCI power toggle, `broken-cd`, and reduced voltage/UHS capabilities did not
recover it. Loading a rescue Linux environment through JTAG and then ejecting
and reinserting the powered card did. Linux subsequently identified the card
as a 4-bit, 3.3 V, 50 MHz SDXC device and created `/dev/mmcblk0p1` through
`/dev/mmcblk0p3`.

This procedure uses JTAG only to run temporary recovery firmware and load a
kernel, initramfs, and DTB into DDR. `device program` does not write the SD card
or replace its `/efi/BOOT.BIN`.

### 1. Build a small UART rescue initramfs

The Versal common-image archive contains a static AArch64 BusyBox. The following
creates an initramfs that configures GEM with the validated static address and
opens a root shell on UART1. The kernel uses UART1 for earlycon and keeps
`ttyAMA0` as its full console; the init script opens `ttyAMA1` directly after
the serial driver is available. Both the reference image and newly linked
platform images use the board's native UART1 route to the onboard CP210.

```bash
set -e
export RESCUE_DIR=/tmp/huins-edf-rescue
export RESCUE_INITRAMFS=/tmp/huins-edf-rescue.cpio.gz

rm -rf "$RESCUE_DIR"
mkdir -p "$RESCUE_DIR"/{dev,proc,sys,tmp,run,usr/bin}
tar -xzf "$COMMON_SW/rootfs.tar.gz" -C "$RESCUE_DIR" \
  ./usr/bin/busybox
file "$RESCUE_DIR/usr/bin/busybox" | grep -q 'statically linked'

cat >"$RESCUE_DIR/init" <<'EOF'
#!/usr/bin/busybox sh

BB=/usr/bin/busybox
$BB mount -t devtmpfs devtmpfs /dev
$BB mount -t proc proc /proc
$BB mount -t sysfs sysfs /sys
$BB mount -t debugfs debugfs /sys/kernel/debug
$BB mdev -s
$BB ifconfig lo 127.0.0.1 up

for net_path in /sys/class/net/*; do
  interface=${net_path##*/}
  [ "$interface" = lo ] && continue
  $BB ifconfig "$interface" 192.168.1.57 netmask 255.255.255.0 up
done

$BB stty -F /dev/ttyAMA1 115200 cs8 -cstopb -parenb
exec $BB setsid $BB sh </dev/ttyAMA1 >/dev/ttyAMA1 2>&1
EOF

chmod 0755 "$RESCUE_DIR/init"
(
  cd "$RESCUE_DIR"
  find . -print0 | cpio --null -o --format=newc --owner=0:0 | \
    gzip -9 >"$RESCUE_INITRAMFS"
)
gzip -t "$RESCUE_INITRAMFS"
```

### 2. Load the rescue environment over JTAG

Start `hw_server` locally or tunnel its port from the lab host. Before running
the loader, open the CP210 UART in another terminal and hold Ctrl-C so U-Boot
stops immediately when the loader resumes A72-0:

```bash
picocom -b 115200 /dev/serial/by-id/usb-Silicon_Labs_CP2102N_USB_to_UART_Bridge_Controller_*-if00-port0
```

Set the URL and recovery inputs, then run the checked-in XSCT loader:

```bash
set -e
source <Vitis_install>/Vitis/2025.2/settings64.sh
cd Xilinx_Official_Platforms/huins_vp1902_base

export HW_SERVER_URL=tcp:127.0.0.1:3121
export RECOVERY_BOOT=<path-to-known-good-Huins-reference-BOOT.BIN>
export RESCUE_IMAGE="$COMMON_SW/Image"
export RESCUE_DTB="$PWD/sw/build/platform/image/system.dtb"

test -f "$RECOVERY_BOOT"
test -f "$RESCUE_IMAGE"
test -f "$RESCUE_INITRAMFS"
test -f "$RESCUE_DTB"

xsct hw/xsa_scripts/jtag_edf_rescue.tcl \
  "$HW_SERVER_URL" "$RECOVERY_BOOT" "$RESCUE_IMAGE" \
  "$RESCUE_INITRAMFS" "$RESCUE_DTB"
```

If `device program` stalls while loading a CDO partition, remove board power,
restore power with the EDF card inserted, wait for U-Boot, and rerun the XSCT
command once. A reset without removing power did not clear the original stalled
PMC state.

At the `Versal>` prompt, enter the two commands printed by
`jtag_edf_rescue.tcl`. The second command includes the calculated initramfs size;
for example:

```text
setenv bootargs console=ttyAMA0,115200 earlycon=pl011,mmio32,0xFF010000,115200n8 loglevel=8 ignore_loglevel clk_ignore_unused rdinit=/init cma=512M
booti 0x20000000 0x30000000:0x<initramfs-size> 0x1000
```

Early kernel output and the `~ #` rescue shell use UART1 on the CP210 connection.
Normal kernel-console output switches to UART0 during serial-driver handoff, so
a quiet interval before the UART1 shell appears is expected.

### 3. Reinsert and inspect the EDF card

With the rescue shell running, eject and firmly reinsert the microSD card
without powering off the board. Do not remove power: the purpose is to reset
the card after PLM has configured the SD interface. Confirm that all three
partitions appear:

```sh
BB=/usr/bin/busybox
$BB sleep 5
$BB ls -l /dev/mmcblk0 /dev/mmcblk0p1 /dev/mmcblk0p2 /dev/mmcblk0p3
$BB cat /sys/kernel/debug/mmc0/ios
$BB blkid /dev/mmcblk0p1 /dev/mmcblk0p2 /dev/mmcblk0p3
```

The validated card reported 4-bit SD high-speed operation at 50 MHz and used
partition 1 for the ESP, partition 2 for storage, and partition 3 for EDF root.
Mount and inspect the ESP and root filesystem read-only first:

```sh
$BB mkdir -p /efi /rootfs
$BB mount -o ro /dev/mmcblk0p1 /efi
$BB mount -o ro /dev/mmcblk0p3 /rootfs
$BB sha256sum /efi/BOOT.BIN /efi/Image /efi/system.dtb
$BB cat /rootfs/etc/os-release
```

The recovered card's `BOOT.BIN` was already intact and matched the known-good
Huins reference image supplied as `RECOVERY_BOOT`:

```text
85adaa59aa54368174b1abe0ef402c82aaf285830d07fe13c77128b7c2446b37  /efi/BOOT.BIN
```

If the hashes differ and `/efi/boot.bin.edf-orig` is present, restore only that
known backup:

```sh
test -s /efi/boot.bin.edf-orig
$BB mount -o remount,rw /efi
$BB cp -a /efi/boot.bin.edf-orig /efi/boot.bin
$BB cmp /efi/boot.bin.edf-orig /efi/boot.bin
$BB sync
$BB mount -o remount,ro /efi
```

If no known-good backup exists, power off and repair the ESP from the
development host using the verified `RECOVERY_BOOT`; do not copy an unverified
image into the card from the rescue shell.

### 4. Enter AMD EDF with `kexec`

Use the EDF root filesystem's dynamic loader and `kexec` binary to boot the
card's own kernel and DTB. This avoids another firmware reset and preserves the
working post-reinsert SD state:

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

The validated recovery reached AMD EDF 26.06 with kernel
`6.18.10-xilinx-g4f7afe14f724`, mounted `/dev/mmcblk0p3` read/write, and brought
GEM interface `end0` up at `192.168.1.57`. Verify from the development host:

```bash
ssh amd-edf@192.168.1.57
cat /etc/os-release
findmnt -no SOURCE,FSTYPE,OPTIONS /
ip -4 -br addr show end0
sha256sum /efi/BOOT.BIN
```

This recovery path remains useful for an existing EDF image that does not
contain the platform's SD handoff settings. Newly generated platform software
uses the 3.3 V, 25 MHz Linux configuration described above.

## Run with a Common-Image SD Card

### Complete SD boot

Back up any working media first. Write `package.hw/sd_card.img` to a removable
microSD device using an imaging tool. For example, after independently checking
that `/dev/sdX` is the intended removable device:

```bash
sudo dd if=package.hw/sd_card.img of=/dev/sdX \
  bs=16M status=progress conv=fsync
```

Writing this image destroys the previous contents of the selected device.

Connect the CP210 serial port at 115200 baud, set SW1 to the SD boot setting
specified by the Huins user guide, insert the card, and power-cycle the board.
On Linux hosts the serial device can be selected through its stable path:

```bash
picocom -b 115200 /dev/serial/by-id/usb-Silicon_Labs_CP2102N_USB_to_UART_Bridge_Controller_*-if00-port0
```

After the common image reaches a shell, find the mounted boot partition and run
the application. It is commonly mounted at `/run/media/mmcblk0p1`:

```bash
cd /run/media/mmcblk0p1
xrt-smi examine
chmod +x simple_vadd
./simple_vadd vadd.xclbin
```

The expected result is:

```text
Mismatches: 0/4096
TEST PASSED
```

`device.load_xclbin()` in the host programs the linked PDI through XRT; a
separate `fpgautil` command is not required.

### Already-running platform-compatible Linux image

The accelerator can also be tested without replacing existing boot media when
the running image already uses this platform's linked hardware and device tree
and has a working `zocl` driver and compatible XRT userspace. A stock EDF boot
does not meet those hardware/DT requirements; prepare it using the AMD EDF
procedure above first.
Copy the packaged xclbin and host to the board:

```bash
ssh <user>@<board> 'mkdir -p /tmp/vadd'
scp package.hw/vadd.xclbin simple_vadd <user>@<board>:/tmp/vadd/
ssh <user>@<board>
```

Then run on the board:

```bash
cd /tmp/vadd
xrt-smi examine
chmod +x simple_vadd
./simple_vadd vadd.xclbin
```

This application-copy path completed all 4096 additions with no mismatch after
the board had booted the linked platform. For a common-image deployment, prefer
the XRT 2.20 userspace and `zocl` shipped in the Versal 2025.2 common image;
never copy selected XRT libraries or kernel modules between images.

## Current Limitations

- Vitis 2025.2 hardware emulation cannot link this VP1902 platform because the
  generated `ps_wizard:1.0` TLM model reports that the device is unsupported.
- The third, PL-side DDR SODIMM is not part of the base platform.
- Versal Premium Gen1 has no AI Engine, so there is no AIE domain or AIE example.
- The generated device tree covers the validated base path. Board-specific PHY,
  EEPROM, and remaining peripheral nodes need exact wiring data before addition.
- SD, QSPI, and JTAG are hardware boot selections. Exact SW1 settings and the
  clean generic `v++ --package` SD deployment remain board-validation items.
- Existing EDF images can leave the card uninitialized with U-Boot error `-110`;
  the JTAG recovery procedure above remains available for those images. The
  generated platform now uses a patched U-Boot and an unmodified common-image
  kernel with a 3.3 V, 25 MHz Linux SD configuration. Five consecutive
  full-power handoffs enumerated all three card partitions without an MMC error.
- An existing EDF installation may select a different UART in its own device
  tree. This repository's generated DTB uses native UART1 on the CP210 pair for
  earlycon while retaining `ttyAMA0` as the full kernel console.

See [README.md](README.md) for board wiring, implementation results, and the
hardware-emulation diagnosis.
