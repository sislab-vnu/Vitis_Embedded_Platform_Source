# Vitis Base Platform for the ZCU106 Board

***Version: 2025.2***

This platform comes with common hardware features on the ZCU106 board like GEM and PS DDR4. The platform software includes OpenCV in PetaLinux. It is useful as a base platform for exercising Vitis capabilities and topologies on the ZCU106 board.

## Platform Specification

### General Information

| Type              | Value                       |
| ----------------- | --------------------------- |
| Release Version   | xilinx_zcu106_base_202520_1 |
| Vitis version     | 2025.2                      |
| XRT Tag version   | [202520.2.20.0_PetaLinux](https://github.com/Xilinx/XRT/tree/202520.2.20.0_Petalinux)              |
| Target board      | ZCU106                      |

### Interfaces

| Interface | Region | Details            |
| --------- | ------ | ------------------ |
| UART      | PS     |                    |
| GEM       | PS     |                    |
| USB       | PS     | USB driver enabled |
| SDIO      | PS     |                    |

### Hardware Configurations

| Configuration                 | Values                                                | Details                               |
| ----------------------------- | ----------------------------------------------------- | ------------------------------------- |
| PS DDR Size                   | 8GB (DDR4 SODIMM)                                     |                                       |
| Clocks for Kernels            | 150MHz, 300MHz, 75MHz, 100MHz, 200MHz, 400MHz, 600MHz | Clocks are synchronous to each other. |
| PS DDR Interfaces for Kernels | HP0, HP1, HP2, HP3, HPC0, HPC1                        | They share the same PS DDR.           |
| Interrupts                    | 32 Interrupts are enabled from PL Kernel to PS        |                                       |

### Software Configurations

The software configurations are based on [ZCU106 BSP](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html). Here is the list of additional configurations.

| Configuration                    | Values                                                       | Details |
| -------------------------------- | ------------------------------------------------------------ | ------- |
| Additional Kernel Configurations | CONFIG_CONSOLE_LOGLEVEL_DEFAULT=1                            |         |
| Additional RootFS Components     | DNF<br />e2fsprogs-resize2fs<br />parted<br />libmali-xlnx: disabled<br />xrt, xrt-dev and zocl<br />opencl-clhpp<br />opencl-headers<br />libdrm, libdrm-tests and libdrm-kms<br />packagegroup-petalinux-audio<br />packagegroup-petalinux-gstreamer<br />packagegroup-petalinux-matchbox<br />packagegroup-petalinux-opencv<br />packagegroup-petalinux-v4lutils<br />packagegroup-petalinux-vitisai<br />packagegroup-petalinux-x11<br />imagefeature-package-management<br />auto-login |         |
| Device Tree Modifications        | Add zocl node for XRT<br />Disable default dtg generated axi intc PL node and add the custom node instead |         |

## Create the Platform

The source flow creates the Vivado block design from Tcl, exports an XSA,
generates the Linux software artifacts, and packages both into an extensible
Vitis platform. No Vivado project is checked into the repository.

### Prerequisites

- Linux host with Vivado and Vitis 2025.2 installed
- ZynqMP common image 2025.2, containing at least `u-boot.elf`, `boot.scr`,
  `bl31.elf`, `Image`, `rootfs.ext4`, and `sdk.sh`
- ZCU106 board files installed with Vivado

Set up Vitis and select the common-image directory:

```bash
source /home/tools/xilinx/2025.2/Vitis/settings64.sh

cd Xilinx_Official_Platforms/xilinx_zcu106_base
export COMMON_SW=/path/to/xilinx-zynqmp-common-v2025.2
```

### Create the Vivado design and XSA

The default build creates a pre-synthesis XSA. Vivado executes
`hw/xsa_scripts/xsa.tcl`, which creates the block design from `dr.bd.tcl` and
applies the Vitis platform declarations from `pfm_decls.tcl`.

```bash
make xsa
```

The output is `hw/build/hw.xsa`. To inspect the generated project, open the
`.xpr` under `hw/build/` in Vivado. Treat it as a generated artifact: make
persistent design changes in `hw/xsa_scripts/dr.bd.tcl`, not in the generated
project.

The Makefile does not track every Tcl include as an XSA dependency. Clean the
hardware output before rebuilding after a Tcl design change:

```bash
make -C hw clean
make xsa
```

To create a post-implementation XSA containing the implemented base-platform
bitstream, use:

```bash
make -C hw clean
make xsa PRE_SYNTH=FALSE
```

A flat Vitis application still runs implementation during `v++ -l`; using a
post-implementation base XSA is therefore optional for this platform.

### Generate software and package the platform

Build all stages in one command:

```bash
make all PREBUILT_LINUX_PATH="$COMMON_SW"
```

The same flow can be run in stages:

```bash
make xsa
make linux PREBUILT_LINUX_PATH="$COMMON_SW"
make platform PREBUILT_LINUX_PATH="$COMMON_SW"
```

To package an existing XSA, pass the same absolute XSA path to both commands:

```bash
make linux XSA=/absolute/path/to/hw.xsa \
  PREBUILT_LINUX_PATH="$COMMON_SW"
make platform XSA=/absolute/path/to/hw.xsa \
  PREBUILT_LINUX_PATH="$COMMON_SW"
```

The principal outputs are:

| Output | Path |
|---|---|
| Hardware XSA | `hw/build/hw.xsa` |
| Generated DTB and boot ELFs | `sw/build/platform/boot/` |
| Packaged platform | `platform_repo/xilinx_zcu106_base_202520_1/export/xilinx_zcu106_base_202520_1/` |
| Platform definition | `platform_repo/xilinx_zcu106_base_202520_1/export/xilinx_zcu106_base_202520_1/xilinx_zcu106_base_202520_1.xpfm` |

Verify the platform before using it:

```bash
export XPFM="$PWD/platform_repo/xilinx_zcu106_base_202520_1/export/xilinx_zcu106_base_202520_1/xilinx_zcu106_base_202520_1.xpfm"
test -f "$XPFM"
platforminfo -p "$XPFM"
```

The internal release suffix is `202520_1` for Vitis 2025.2. Do not change it
to `202520_2`.

## Create a Vitis `vadd` Design

The following commands use the `vadd` kernel and native-XRT host sources
installed with Vitis 2025.2. Start in the platform directory after setting
`XPFM` as shown above.

### Compile and link the hardware

```bash
export VADD_SRC="$XILINX_VITIS/samples/vadd/src"
mkdir -p app/vadd
cd app/vadd

v++ -c -t hw --platform "$XPFM" -k vadd \
  -I"$VADD_SRC" -o vadd.xo "$VADD_SRC/vadd.cpp"

v++ -l -t hw --platform "$XPFM" \
  -o vadd.xclbin vadd.xo
```

The link step implements the complete flat hardware design and places its
bitstream in `vadd.xclbin`. On the verified build it completed timing with WNS
`0.810 ns`.

### Cross-compile the host application

Install the Yocto SDK once if the common-image directory does not already
contain an installed SDK:

```bash
"$COMMON_SW/sdk.sh" -y -d "$HOME/xilinx-zynqmp-common-v2025.2-sdk"
```

Copy the sample host sources into the application directory:

```bash
cp "$VADD_SRC"/host.cpp .
cp "$VADD_SRC"/cmdlineparser.cpp "$VADD_SRC"/cmdlineparser.h .
cp "$VADD_SRC"/logger.cpp "$VADD_SRC"/logger.h .
```

For a complete 4096-element validation, correct the byte count in the copied
`host.cpp` before compiling:

```diff
-    if (std::memcmp(bo_out_map, bufReference, DATA_SIZE))
+    if (std::memcmp(bo_out_map, bufReference, vector_size_bytes))
```

Then source the SDK environment and build:

```bash
source "$HOME/xilinx-zynqmp-common-v2025.2-sdk/environment-setup-cortexa72-cortexa53-amd-linux"

$CXX -std=c++17 -I. \
  host.cpp cmdlineparser.cpp logger.cpp \
  -o simple_vadd -lxrt_coreutil -luuid -pthread
```

Warnings from the sample `logger.cpp` about deprecated `std::ptr_fun` and
`std::not1` are harmless.

## Package and Run the Platform

A platform is consumed by `v++`; it is not itself an executable. To boot and
run it, package the linked xclbin, Linux image, root filesystem, and host
program into an SD-card image.

Return to a shell with the Vitis 2025.2 environment sourced, then run from the
`app/vadd` directory:

```bash
v++ -p -t hw --platform "$XPFM" \
  --package.boot_mode sd \
  --package.out_dir package.hw \
  --package.rootfs "$COMMON_SW/rootfs.ext4" \
  --package.kernel_image "$COMMON_SW/Image" \
  --package.sd_file simple_vadd \
  -o package.hw/vadd.xclbin vadd.xclbin
```

This produces:

- `package.hw/sd_card.img`: complete partitioned SD-card image
- `package.hw/BOOT.BIN`: FSBL, PMU firmware, platform bitstream, DTB, ATF, and
  U-Boot
- `package.hw/sd_card/`: individual FAT-partition files
- `package.hw/vadd.xclbin`: packaged accelerator binary

Write `package.hw/sd_card.img` to an SD card with an imaging tool, select SD
boot mode on the ZCU106, connect the serial console, and power on the board.
Be certain that the selected destination is the removable SD card; writing an
image destroys its previous contents.

After Linux boots, locate the boot partition (commonly
`/run/media/mmcblk0p1`) and run:

```bash
cd /run/media/mmcblk0p1
xrt-smi examine
chmod +x simple_vadd
./simple_vadd -x vadd.xclbin
```

The expected result is:

```text
TEST PASSED
```

`zocl`, the FPGA manager, and a matching XRT userspace must be available. The
host call to `device.load_xclbin()` programs the linked PL design, so a
separate `fpgautil` command is not required for this flat xclbin workflow.

### Run on an already booted compatible image

If the board already runs a compatible ZynqMP Linux image with `zocl` and XRT,
copy only the application artifacts and run the same host command:

```bash
scp simple_vadd vadd.xclbin <user>@<board>:/tmp/vadd/
ssh <user>@<board>
cd /tmp/vadd
xrt-smi examine
./simple_vadd -x vadd.xclbin
```

### Current site-board limitation

The application and all PL/PS data paths have been validated on the physical
ZCU106: repeated runs completed with all 4096 values correct. That validation
used a Vitis-kernel kexec handoff from the restored EDF boot stack.

The newly generated full SD boot stack has not yet reached Linux on this board;
the leading suspect is FSBL dynamic-DDR initialization of the 8GB SODIMM. Do
not overwrite the only working boot media without a backup, serial-console
access, and a tested recovery path. See [TESTING.md](TESTING.md), especially
sections 4.3 through 4.5, for the boot failure, kexec procedure, required
`PL0_REF`/LPD-AFI initialization, and hardware `vadd` evidence.

For additional application-development background, see the
[Vitis tutorials](https://github.com/Xilinx/Vitis-Tutorials) and
[Vitis templates](https://github.com/Xilinx/vitis_templates/).
