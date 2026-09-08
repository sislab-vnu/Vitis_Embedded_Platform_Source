# Huins VP1902 Base Platform (custom board)

***Version: 2025.2 (202520_1)*** | **Status: hardware link and core physical-board flow verified**

See [USAGE.md](USAGE.md) for build and deployment commands,
[JTAG_XSDB_GUIDE.md](JTAG_XSDB_GUIDE.md) for board control and recovery, and
[TROUBLESHOOTING.md](TROUBLESHOOTING.md) for the complete problem and solution
record.

Site addition on the `2025.2-sislab` branch: an extensible Vitis base platform for the
custom Huins board built around the **Versal Premium `xcvp1902`** device. Ported from
`xilinx_vck190_base` (the closest platform in this repository: Versal Gen1, AI Engine,
same extensible feature set and PetaLinux flow).

## Target device

| Type | Value |
|---|---|
| Device | `xcvp1902-vsva6865-2MP-e-S` - **confirm 2MP vs 2LP bin with Huins** (OPN `XCVP1902-2MSEVSVA6865`) |
| Platform name | `huins_vp1902_base_202520_1` |
| Vitis | 2025.2 |
| Common image | `xilinx-versal-common-v2025.2` (shared with all Versal platforms here) |

## Hardware status

Verified on this workstation's Vivado 2025.2 (empirically, per-IP):

| IP | on `xcvp1902-vsva6865-2MP-e-S` |
|---|---|
| `ps_wizard:1.0` | **OK** - use this instead of `versal_cips` (CIPS 3.4 rejects xcvp1902) |
| `axi_noc:1.1` (Gen1 NOC) | **OK** |
| `axi_noc2:1.1`, `ai_engine:2.0` | NOT supported (Gen2-only) |

Key hardware facts for the port:
- **Versal Premium Gen1 has no AI Engines** - the vck190 `ai_engine` cell and its
  clocks must be dropped when regenerating the design.
- No CED exists for vpk180/xcvp1902 (`ext_platform` and `versal_common_platform`
  CEDs are board-driven: vck190/vek280/vek385/vrk160/165 only).

Board facts extracted from `huins_mfp-vp1902_userguide.pdf` (Huins MFP-VP1902-S):

| Item | Value |
|---|---|
| FPGA | `XCVP1902-2MSEVSVA6865` - **confirmed** by Huins reference BD (`vp1902s_top.tcl`, part `xcvp1902-vsva6865-2MP-e-S`) |
| PS DDR4 | 2x SODIMM 32GB, DDR4-2666 (SODIMM 0/1, via PS DDRMC) |
| PL DDR4 | 1x SODIMM 32GB (SODIMM 2, PL area - out of base-platform scope) |
| DDR4 MIG @NoC | DDR4 SDRAM, SoDIMM, bin DDR4-3200AA(22-22-22), sys clock 200 MHz; MC0 = banks 821-823, MC1 = banks 700-702; package pins from User Guide A.3 |
| QSPI | dual-parallel flash x2, PMC MIO 0..12 |
| USB | USB 2.0 (ULPI), PMC MIO 13..25 |
| SD | microSD 3.0: `PMC_SD1_30AD_PERIPHERAL` MIO 26:36, `4Bit_autodir`, `SD_3.0_AUTODIR`, high_speed |
| Ethernet | `PS_ENET1_PERIPHERAL` RGMII MIO 38:49; `PS_ENET1_MDIO` on EMIO (XIO BM13/BL13, LVCMOS18); GEM1 ref clk 125 MHz |
| USB | `PS_USB3_PERIPHERAL` on PMC MIO 13:25 (USB-2.0 ULPI PHY, no GT) |
| UART0/1, I2C0/1 | **EMIO**, LVCMOS18 (UART0 console on CP210 XIO BK13/BL14; UART1 XIO BK17/BL18; UART 115200; I2C0 XIO BM17/BM18, I2C1 BL16/BM16) |
| PL clocks (ps_wizard) | PL0 100 / PL1 300 / PL2 200 / PL3 125 MHz; NOC ref 1000 MHz |
| DDR4 NoC | `axi_noc:1.1`, DDR4_SDRAM, `SODIMMs`, `DDR4-3200AA(22-22-22)`, RANK 2, NUM_MC 2 / NUM_MCP 2, NUM_SI 10, NUM_CLKS 12; DDR sys clocks are **external ports** `C0_DDR4_SYS`/`C1_DDR4_SYS` (board 200 MHz OSCs) |
| Boot | JTAG/QSPI/SD selectable (SW1) |
| AI Engine | none (Versal Premium Gen1) |

**EMIO console caveat**: UART0/1 route through EMIO to PL XIO pins. With a
pre-synth (PL-empty) platform there is **no serial console until a PL bitstream is
loaded**; networking via GEM1 (MIO) is unaffected. Early-console visibility
requires a linked or post-implementation design. HDIO bank 408 is supplied at
1.8 V, so its GEM1 MDIO, UART, and I2C EMIO pins use `LVCMOS18`.
The onboard CP210 is connected to the vendor design's UART1 XIO pair
(`BK13` RX, `BL14` TX); this platform routes PS UART0 to that pair because the
Vitis common-image PLM, TF-A, U-Boot, and generated device tree select UART0.
Consequently, the reference `BOOT.BIN` uses UART1 on the CP210, while a linked
platform PDI uses UART0 on the same connector.

The manually rebuilt BD generates the hardware XSA and forces inclusion of the
Versal pre-synthesis PDI. Remaining board-validation items:

1. **Device tree**: SDT is generated from the XSA without borrowing another
   board's DTS. Add Huins-specific PHY, EEPROM, and other board-level nodes when
   their exact wiring is available.
2. **Physical validation**: EMIO console, SD detection, GEM link, DDR, and a
   linked `vadd` application are validated; confirm deployment boot modes and
   the remaining board peripherals.

## Build

The default build creates the extensible platform used by Vitis application
linking:

```bash
source <Vitis_install>/Vitis/2025.2/settings64.sh
make all PREBUILT_LINUX_PATH=/opt/xilinx/platform/xilinx-versal-common-v2025.2
```

Output: `platform_repo/huins_vp1902_base_202520_1/export/...`.

See [USAGE.md](USAGE.md) for prerequisites, platform features, staged and
post-implementation builds, the complete `vadd` compile/link/package flow, and
board deployment instructions, including the validated AMD EDF image path.

## Hardware-link validation

A Vitis 2025.2 hardware link of the sample `vadd` kernel completed successfully
against the generated platform. Versal embedded linking produced a linked XSA
containing `vpl_gen_fixed.pdi`.

| Check | Result |
|---|---|
| Routing | 16,091/16,091 routable nets; zero routing errors |
| Timing | WNS 5.888 ns, TNS 0; WHS 0.036 ns, THS 0 |
| I/O DRC | zero `NSTD-2` and `UCIO-1`; no unconstrained ports |
| HDIO bank 408 | GEM1 MDIO, I2C0/1, and UART0/1 placed as `LVCMOS18` |
| DDRMC | MC0 `DDRMC_S2X0Y0`, MC1 `DDRMC_S0X0Y0` |
| Compute unit | `vadd_1`, control `0xA4010000`, interrupt 1, 100 MHz |
| Memory | `gmem0` to `S06_AXI`, `gmem1` to `S07_AXI` |

The linked `vadd` design and its XRT host were also validated on the physical
board with 4096/4096 results correct. Physical validation of the remaining
peripherals and deployment boot modes is still pending.

An EDF recovery run also validated the JTAG, UART1, GEM1, and removable-SD
paths. Boot ROM and PLM read the SD `BOOT.BIN`, but U-Boot then reported `Card
did not respond to voltage select! : -110`. A JTAG-loaded rescue kernel created
the SD host but could not initialize the still-inserted card. Ejecting and
reinserting the card while rescue Linux remained powered caused immediate
4-bit, 3.3 V, 50 MHz enumeration; `kexec` then booted AMD EDF 26.06 from
`/dev/mmcblk0p3`. The on-card `BOOT.BIN` was intact and matched the reference
image. See [JTAG_XSDB_GUIDE.md](JTAG_XSDB_GUIDE.md) for the complete board-control
and recovery procedure.

### SD firmware handoff correction

The platform now generates separate device trees for the two software stages.
The U-Boot control DT is `sw/build/platform/boot/u-boot.dtb`; it describes the
SDIO1 reset and keeps signaling at 3.3 V with `no-1-8-v`. The Linux runtime DT
is `sw/build/platform/image/system.dtb`. It also keeps signaling at 3.3 V and
limits the bus to 25 MHz with zero SD high-speed phase, matching the electrical
state proven by U-Boot. A custom platform BIF preserves the two trees instead of
allowing Vitis `set_dtb()` to replace the U-Boot DT with the Linux DT.

U-Boot uses the included early host-reset patch:

- `sw/prebuilt_linux/patches/0001-mmc-zynq_sdhci-reset-the-host-controller.patch`

No Linux source patch is required. Testing with the unmodified Vitis 2025.2
common-image kernel at source revision
`31626ef92ff11f9d3dee01926720572666fcc65a` isolated two handoff failures. A
1.8 V switch corrupted CID responses because the board does not provide a
working SD voltage switch. At 3.3 V, raising the already-initialized card from
U-Boot's 25 MHz state to 50 MHz caused the first post-switch command to time out.
With `no-1-8-v`, `max-frequency = <25000000>`, and
`clk-phase-sd-hs = <0>, <0>`, Linux enumerated the 59.5 GiB SDXC card and all
three partitions immediately after U-Boot read a 33,083,904-byte image from it.
Five consecutive full-power cold boots reproduced the complete U-Boot read and
Linux enumeration without an MMC error.

## Hardware-emulation limitation

`make xsa` creates `hw/build/hw_emu/hw_emu.xsa`, but it is intentionally not
packaged in the platform because Vitis 2025.2
cannot link an hw_emu kernel for `xcvp1902`. The `ps_wizard:1.0` simulation
generator emits these files in the integrated Vivado project:

```text
//Empty class
//This device/part is not supported
```

Consequently, `v++ -l -t hw_emu` reaches `config_hw_emu.compile` and fails while
compiling `vitis_design_ps_wizard_0_0.cpp` with `invalid use of incomplete type
'class ps_wizard_v1_0_7_tlm'`. The platform PFM connectivity is accepted by
`cfgen`; the unsupported VP1902 TLM model is the remaining blocker. Software
emulation is not a fallback because Vitis 2025.2 no longer supports `sw_emu`.

### Direct QEMU validation evidence

The following records an exploratory validation and is not a repository build
target; it requires temporary generated files and emulation-only DT changes.

The packaged Linux artifacts were validated independently of linked hw_emu with
the exact VP1902 standalone PS model installed with Vitis 2025.2:

```text
<Vitis>/data/emulation/qemu/comp/qemu/sysroots/x86_64-petalinux-linux/
  qemu-hw-devicetrees/board-versal-xcvp1902-ps-virt.dtb
```

Direct Linux boot requires `-M arm-generic-fdt,linux=on`. AMD's QEMU source sets
the generic machine's `secure_boot` flag unless the `linux` machine property is
true; omitting it aborts in `do_cpu_reset` with `Assertion '!info->secure_boot'
failed` while loading the AArch64 kernel.

The standalone invocation used this form (paths abbreviated):

```bash
qemu-system-aarch64 \
  -M arm-generic-fdt,linux=on \
  -display none -monitor none \
  -hw-dtb board-versal-xcvp1902-ps-virt.dtb \
  -serial file:ppu0.log \
  -serial file:ppu1.log \
  -chardev file,id=serial2,path=uart0.log \
  -chardev file,id=serial3,path=uart1.log \
  -kernel Image \
  -dtb system-qemu.dtb \
  -append "earlycon console=ttyAMA0,115200 clk_ignore_unused root=/dev/mmcblk0p2 rw rootwait" \
  -drive file=sd_card.img,format=raw,if=sd,index=1
```

The QEMU hardware DTB maps PMC debug UARTs to `serial0`/`serial1`, PS UART0 to
`serial2`, PS UART1 to `serial3`, and SD1 to drive index 1. Linux enumerates the
only enabled SD controller as `mmc0`, so its root partition is `mmcblk0p2`, not
`mmcblk1p2`. The generated Linux DTB describes the UART as PL011, hence the
console name `ttyAMA0` rather than `ttyPS0`.

Because direct kernel boot intentionally bypasses PLM and Versal platform
management firmware, `system-qemu.dtb` was a temporary copy of the generated
`system.dtb` with these emulation-only changes:

- Replace the SD1 `clk_xin`, `clk_ahb`, and `gate` firmware clock references
  with 200 MHz/100 MHz fixed clocks and remove its power-domain reference.
- Replace UART0/1 `uartclk` and `apb_pclk` firmware clock references with 100 MHz
  fixed clocks and remove their power-domain references.
- Leave the real-board `system.dtb` unchanged.

The generated kernel 6.12.40 and SD image reached all of these checkpoints:

```text
mmcblk0: mmc0:4567 QEMU! 4.00 GiB
mmcblk0: p1 p2
EXT4-fs (mmcblk0p2): mounted filesystem ... r/w
VFS: Mounted root (ext4 filesystem) on device 179:2
Run /sbin/init as init process
Welcome to PetaLinux 2025.2+release-S11151021 (scarthgap)!
Started Serial Getty on ttyAMA0
Reached target Login Prompts
```

For a pristine common image, the first-boot `ldconfig.service` and
`run-postinsts.service` take several minutes under TCG. They were masked on the
kernel command line for the final login-prompt check; mounting the root filesystem
and starting systemd were also verified without those masks.

This route verifies the VP1902 PS model and packaged kernel, Linux DTB topology,
SD image, and root filesystem. It does not validate PLM, U-Boot, the firmware
clock/power services, the second A72 (PSCI returned `-22` in direct boot),
programmable logic, accelerator kernels, or the blocked linked hw_emu flow.
Firmware-managed devices other than the patched UART and SD remain deferred, as
expected when PLM is bypassed.

The split VCK190 cosimulation DTBs cannot substitute for this standalone VP1902
model. They require both PMC and PL remote-port peers; without a functioning PL
peer, the PS/PMC pair stalls at time zero or triggers an `rp_write` assertion.

## Test the Platform

Follow the repository's [end-to-end usage guide](USAGE.md) to build and inspect
the platform, link the Vitis 2025.2 `vadd` kernel, cross-compile the checked-in
XRT host, package an SD image, and run the 4096-element test on the Huins board.
