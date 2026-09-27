# Huins VP1902 Bring-up Problems and Solutions

This document records the problems encountered while creating and validating
`huins_vp1902_base` with Vivado and Vitis 2025.2. It separates confirmed fixes
from diagnostic experiments that did not solve the problem. It also records
remaining limitations so that an exploratory workaround is not mistaken for a
supported platform feature.

The platform uses AMD's internal 2025.2 version suffix `202520_1`; it must not
be changed to `202520_2`.

## Final validated state

The following paths have been validated:

| Area | Result |
|---|---|
| Hardware implementation | Routed, timing closed, and free of `NSTD-2` and `UCIO-1` errors |
| PS memory | Two DDR4 SODIMMs through DDRMC0 and DDRMC1; about 64 GB visible in Linux |
| Linux SD handoff | Five consecutive full-power tests passed |
| SD signaling | 4-bit, 3.3 V, maximum 25 MHz in Linux |
| Accelerator | 4096-element `vadd`, zero mismatches, `TEST PASSED`, exit status zero |
| EDF runtime | Kernel 6.18.10, XRT 2.23.0, `zocl` 2.23.0, one ready edge device |

The clean generic `v++ --package` SD-card deployment and exact SW1 positions
remain separate board-validation items. The final accelerator test used the
documented EDF integration path and a linked package loaded through JTAG.

## Hardware design problems

### 1. `versal_cips` rejected the VP1902

**Symptom**

Vivado rejected `versal_cips:3.4` for `xcvp1902`.

**Cause**

The CIPS IP available in Vivado 2025.2 does not support this Versal Premium
Gen1 part. The custom Huins board also has no Vivado board preset.

**Solution**

Use `ps_wizard:1.0` and reproduce the PS/PMC configuration from the Huins
reference design. The active implementation is in `hw/xsa_scripts/bd.tcl`.

**Validation**

The resulting design generated an XSA, completed a Vitis hardware link, closed
timing, and ran `vadd` on the physical board.

### 2. Gen2 NoC and AI Engine IP were unsupported

**Symptom**

`axi_noc2:1.1` and `ai_engine:2.0` were reported as unsupported.

**Cause**

VP1902 is Versal Premium Gen1. `axi_noc2` is a Gen2 choice, and this device has
no AI Engines.

**Solution**

Use `axi_noc:1.1`. Remove the AI Engine cell, AIE clocks, AIE interrupts, AIE
PFM declarations, and the AIE software domain.

**Validation**

The exported platform contains the Gen1 NoC, no AIE domain, and five valid PL
kernel clocks.

### 3. No CED or Huins board part existed

**Symptom**

No `ext_platform` or `versal_common_platform` CED covered the Huins VP1902,
and no Huins board part was installed.

**Cause**

AMD's available CEDs are board-driven and target evaluation boards rather than
this custom board.

**Solution**

Target `xcvp1902-vsva6865-2MP-e-S` directly and construct the BD from the Huins
reference Tcl. Do not set an unrelated AMD board part.

### 4. The complete Huins demonstration design was not a suitable base platform

**Symptom**

The vendor design included unrelated HDMI, CSI, Aurora/GT, PL Ethernet,
VIO/debug, and PL-DDR logic. Some blocks required unavailable Huins RTL such as
`axi_eth_support` and `csi_rx_tuser`.

**Cause**

The vendor project is a complete demonstration design rather than an
extensible Vitis shell.

**Solution**

Retain the PS/PMC, dual DDRMC NoC, clocks, resets, platform AXI interfaces, and
interrupt infrastructure. Remove unrelated demonstration peripherals and the
third PL-side DDR SODIMM.

### 5. Inherited PFM declarations described the wrong platform

**Symptom**

Early declarations referenced nonexistent `/noc_ddr4` and `/noc_lpddr4`
cells, old memory topology, AIE interrupts, and unrelated clocks.

**Cause**

The initial skeleton inherited VCK190/VC1902 platform declarations.

**Solution**

Declare the interfaces actually present in the VP1902 design:

- DDR kernel ports `S06_AXI` through `S09_AXI`.
- One fixed `M00_AXI` control path to the AXI interrupt controller.
- Expandable `M01_AXI` through `M15_AXI` control ports as PFM declarations.
- One 32-input AXI interrupt controller.
- 100, 200, 300, 400, and 600 MHz kernel clocks.

**Validation**

`cfgen` accepted the topology. `vadd` linked at control address `0xA4010000`,
used interrupt 1, and connected memory through `S06_AXI` and `S07_AXI`.

### 6. DDR pins and placement were not supplied automatically

**Symptom**

Without explicit constraints, the custom DDR ports were unplaced and would
produce unconstrained-I/O DRC failures.

**Cause**

There is no board part to provide package pins. The user guide includes ECC
pins, while the active interface is 64-bit data without the extra ECC byte.

**Solution**

Use `hw/xsa_scripts/huins_vp1902_ddr.xdc` with the Huins User Guide A.3 pin
mapping. Constrain DQ0-63, DM0-7, and DQS0-7; omit ECC-only DM8, DQ64-71, and
DQS8.

**Validation**

MC0 placed at `DDRMC_S2X0Y0`, MC1 placed at `DDRMC_S0X0Y0`, I/O DRC was clean,
and Linux reported approximately 64 GB of memory.

### 7. HDIO bank 408 used the wrong voltage assumption

**Symptom**

GEM1 MDIO, I2C, and UART EMIO pins risked `NSTD-2`, electrical mismatch, or
unreliable board operation.

**Cause**

HDIO bank 408 is powered at 1.8 V on the Huins board.

**Solution**

Apply `LVCMOS18` to GEM1 MDIO, I2C0/1, and UART0/1 in
`hw/xsa_scripts/huins_vp1902_io.xdc`.

**Validation**

The linked implementation had no `NSTD-2`, no `UCIO-1`, and no unconstrained
ports.

### 8. The serial console disappeared with the pre-synthesis XSA

**Symptom**

The pre-synthesis platform produced no usable CP210 serial console.

**Cause**

Both PS UARTs use EMIO and require routed PL logic. The CP210 is physically tied
to the board's UART1 pair at `BK13`/`BL14`. Remapping UART0 to those package pins
left the final linked PDI silent even though Linux and GEM were running.

**Solution**

Preserve native UART1 on `BK13`/`BL14` and leave UART0 on `BK17`/`BL18`. Select
`serial1` in U-Boot and use UART1 earlycon in Linux, but keep `ttyAMA0` as the
full kernel console. Selecting `console=ttyAMA1` consistently stopped normal
Linux boot during serial-driver handoff. Enable `huins-uart-getty.service` to
provide the login prompt on `ttyAMA1`. Use a linked application PDI, or an
implemented base PDI, when the EMIO serial route is required.

**Validation**

The corrected linked PDI is physically validated on CP210 for U-Boot, Linux
earlycon, and the `ttyAMA1` EDF login prompt. Both serial devices exist, and the
split-console EDF boot completed with networking and TCF available.

### 9. A pre-synthesis XSA could omit boot-critical initialization

**Symptom**

A pre-synthesis Versal platform could be exported without the PDI needed to
initialize the PS and PMC.

**Cause**

`write_hw_platform` does not always include a pre-synthesis PDI by default.

**Solution**

Set `platform.forceEnablePreSynthPDI true` before writing the XSA.

**Validation**

The platform linked successfully and the linked XSA contained
`vpl_gen_fixed.pdi`.

### 10. Post-implementation boot generation needed the implemented PDI

**Symptom**

The build reported:

```text
ERROR: Post-implementation PDI not found at ...
```

**Cause**

`bootgen` needs the implementation PDI; an XSA alone is not a substitute.

**Solution**

Copy `vitis_design_wrapper.pdi` to `hw/build/hw.pdi` in the implemented flow.
The software Makefile verifies that file before generating `BOOT.BIN`.

## Build and platform-generation problems

### 11. Vitis environment or common-image paths were missing

**Symptoms**

```text
ERROR: 'XILINX_VITIS' variable not set
PREBUILT common images cannot be found at ...
ERROR: 'PREBUILT_LINUX_PATH' is not accesible
```

**Cause**

The Vitis environment was not sourced, or the Versal common-image directory
was absent or passed through recursive Makefiles as a relative path.

**Solution**

Source Vitis 2025.2 and use absolute paths:

```bash
source /home/tools/xilinx/2025.2/Vitis/settings64.sh
make all PREBUILT_LINUX_PATH=/absolute/path/to/xilinx-versal-common-v2025.2
```

The current Makefiles normalize user-supplied XSA, common-image, and U-Boot
paths before entering subdirectories.

### 12. The internal platform suffix looked wrong but was correct

**Symptom**

It was tempting to rename the platform to `huins_vp1902_base_202520_2` because
the installed tools are Vitis 2025.2.

**Cause**

AMD's internal release naming maps Vitis 2025.2 to `202520_1` for these
platforms.

**Solution**

Keep `VERSION ?= 202520_1` and `VER ?= 202520.1` in `platform.mk`.

### 13. A stale generated platform blocked export

**Symptom**

Vitis returned `StatusCode.ALREADY_EXISTS` for the platform component.

**Cause**

The output directory already contained a generated component with the same
name.

**Solution**

Remove only the stale generated component, run `make clean`, or export to a
fresh validation directory. Do not change source files or the platform name to
work around generated state.

### 14. The VPK180 board device tree described the wrong board

**Symptom**

The original DT flow selected `versal-vpk180-reva` because VPK180 uses a
related device family.

**Cause**

Matching silicon does not imply matching board wiring.

**Solution**

Generate SDT directly from the VP1902 XSA and apply only the Huins user DTSI.
Do not import VPK180 peripheral descriptions.

### 15. U-Boot and Linux needed different device trees

**Symptom**

Using one DT and `set_dtb()` allowed the Linux runtime DT to replace the DT
embedded for U-Boot.

**Cause**

U-Boot needs reset/control properties, while Linux needs conservative runtime
timing. Vitis previously treated one DT as both artifacts.

**Solution**

Generate and package two trees:

| Consumer | File | Purpose |
|---|---|---|
| U-Boot | `sw/build/platform/boot/u-boot.dtb` | Controller reset and 3.3 V setup |
| Linux | `sw/build/platform/image/system.dtb` | Runtime root, voltage, frequency, and phase settings |

Use `platform/linux.bif` to load `boot/u-boot.dtb`, and pass the Linux DT
separately to `domain.set_dtb()` in `platform/generate_platform.py`.

**Validation**

The exported U-Boot and Linux DTs remained distinct, and the full handoff
passed five full-power tests.

### 16. The Yocto SDK environment interfered with packaging

**Symptom**

Running `v++ -p` in the same shell used for host cross-compilation could inherit
unexpected compiler and sysroot variables.

**Cause**

The common-image SDK modifies the shell environment.

**Solution**

Cross-compile the host in the SDK shell. Open a fresh shell, source only Vitis,
and package there.

**Validation**

The resulting host and packaged xclbin passed all 4096 additions on the board.

## SD firmware-to-Linux problems

### 17. U-Boot inherited stale SDHCI state

**Symptom**

```text
Card did not respond to voltage select! : -110
```

**Cause**

The Versal SD host could retain firmware/controller state that was not cleared
early enough by the stock U-Boot probe path.

**Solution**

Build U-Boot revision `5e0d8abc7e092b62a5de17aa7aadfad7af5f0f59` with:

```text
sw/prebuilt_linux/patches/0001-mmc-zynq_sdhci-reset-the-host-controller.patch
```

Both U-Boot and Linux DTs identify `VERSAL_RST_SDIO_1`.

### 18. The SD 1.8 V transition corrupted card identification

**Symptoms**

CID CRC/end-bit failures and voltage-selection timeouts occurred after Linux
attempted the 1.8 V switch. Failed SDHCI state included `Host ctl2=0x8`.

**Cause**

The board does not provide a working SD signaling-voltage switch.

**Solution**

Add `no-1-8-v` to both U-Boot and Linux DTs so signaling remains at 3.3 V.

### 19. Linux's 25-to-50 MHz transition broke the handoff

**Symptom**

At 3.3 V, the first command after Linux raised the U-Boot-initialized card from
25 MHz to 50 MHz timed out.

**Cause**

The firmware-proven state was stable at 25 MHz, but not after Linux selected
high-speed timing at 50 MHz.

**Solution**

Use the following Linux SD properties:

```dts
no-1-8-v;
max-frequency = <25000000>;
clk-phase-sd-hs = <0>, <0>;
```

No Linux source patch is required.

**Validation**

The unmodified Vitis 2025.2 common-image kernel enumerated the 59.5 GiB card
and `p1 p2 p3` immediately after U-Boot read a 33,083,904-byte image. Five
consecutive full-power runs passed without MMC errors.

### 20. Controller reset did not recover a card already left in a bad state

**Symptom**

U-Boot and rescue Linux saw card presence, but no `mmcblk0` device appeared.
Controller reset, SDHCI power toggling, `broken-cd`, and capability reductions
did not initialize the still-inserted card.

**Cause**

The card itself remained in a bad electrical/protocol state. Resetting only the
host controller did not remove card power.

**Solution or recovery**

Keep the board powered, eject and reinsert the card, and then use `kexec` to
enter EDF without another firmware reset. For a true cold test, remove all
board, USB, and JTAG power long enough to eliminate back-power to the slot.

**Validation**

Powered reinsertion immediately produced 4-bit, 3.3 V, 50 MHz enumeration in
the rescue kernel and exposed all three EDF partitions.

### 21. USB/JTAG back-power made a normal power cycle unreliable

**Symptom**

Turning off the main board supply did not always reset the SD card. A following
test could fail before U-Boot even though the previous test had passed.

**Cause**

USB or JTAG connections could continue supplying enough power to preserve card
or board state.

**Solution**

For cold validation, shut down with the front-panel `PWR SW`, switch off and
unplug the rear ATX PSU, disconnect all USB/JTAG paths, and wait at least ten
seconds with the card inserted. Reconnect the ATX input, switch on its rear
rocker, press `PWR SW`, and then reconnect the host paths. Do not operate
clock-module `SW6`; it configures a clock divider, not board power. Gate every
Linux test on a successful U-Boot read first.

### 22. Direct Linux SDHCI register access wedged the A72

**Symptom**

Using Linux `devmem` against live SDHCI registers wedged the processor and made
later observations unreliable.

**Cause**

The kernel driver and hardware were active while registers were accessed
outside the driver's synchronization and power-management rules.

**Solution**

Do not use Linux `devmem` for this controller. Stop the A72 and inspect physical
registers through XSDB when a snapshot is required.

## EDF, JTAG, and accelerator problems

### 23. A stock EDF boot did not provide the linked platform

**Symptom**

Copying only the host and xclbin to an unmodified EDF installation did not
provide a usable accelerator device.

**Cause**

The boot PDI, platform DT, kernel, `zocl`, XRT userspace, and xclbin metadata
must describe a compatible platform.

**Solution**

Keep EDF's kernel, root filesystem, XRT, and `zocl`, but install the linked
`boot.bin`, platform DT, a separate systemd-boot entry, and the matching host
and xclbin. The complete procedure is in `USAGE.md`.

### 24. The platform root PARTUUID did not identify the EDF root partition

**Symptom**

The generated common-image root argument did not point to an arbitrary EDF
card's root partition.

**Cause**

Common-image and EDF cards use different layouts and partition UUIDs. The
validated EDF card uses p1 `esp`, p2 `storage`, and p3 `root`.

**Solution**

Read the EDF root partition's actual PARTUUID and override `root=` in the new
systemd-boot entry.

### 25. Mixing kernels, XRT, or `zocl` modules caused invalid test results

**Symptoms**

- `modprobe: FATAL: Module zocl not found`
- `insmod: ERROR: could not insert module ...: Invalid module format`
- No `/dev/dri/renderD128` or no XRT device 0.

**Cause**

Kernel ABI, `zocl`, XRT userspace, and the root filesystem are version-coupled.
For example, the Vitis 2025.2 common kernel is 6.12.40, while the validated EDF
kernel is 6.18.10.

**Solution**

Use EDF's XRT 2.23.0 and matching `zocl` 2.23.0 unchanged for EDF. Use the
common image's XRT 2.20 stack only with the common image. Never copy selected
libraries or kernel modules between the two environments.

### 26. `IRQ index 32 not found` looked fatal but was not

**Symptom**

EDF printed:

```text
IRQ index 32 not found
```

during initial `zocl` probing.

**Cause**

This warning occurs during initial resource probing on the validated platform.

**Solution**

Do not fail the test on this warning alone. Require `/dev/dri/renderD128`, one
ready device from `xrt-smi examine`, successful xclbin load, and successful
compute-unit execution.

**Validation**

`zocl` initialized, the compute-unit interrupt registered, and all 4096
additions passed.

### 27. Root SSH access was unavailable during automated validation

**Symptom**

The board responded on the network, but root SSH credentials were unavailable
and the serial login required credentials.

**Cause**

The EDF image's account policy did not permit the intended unattended root SSH
session.

**Solution**

Use the root-owned TCF agent on port 1534 for controlled lab file transfer and
process execution. Confirm the board IP from the lab host before use. This is a
lab automation workaround, not a deployment requirement.

**Validation**

TCF `ProcessesV1` launched `/storage/simple_vadd /storage/vadd.xclbin`, captured
`Mismatches: 0/4096` and `TEST PASSED`, and recorded exit status zero.

### 28. A stale or mismatched linked artifact caused an A72 SError

**Symptom**

`vadd` triggered an asynchronous SError in `xrt_cu_hls_init()` while probing
the HLS compute unit.

**Cause**

The board was running a base or mismatched PDI while the test used an older
September 1 linked xclbin. The CU address existed in xclbin metadata but was not
reachable in the active hardware.

**Solution**

Treat `BOOT.BIN`, the platform DT, and xclbin as one matched set. The final
package uses the current UART1-linked XSA and split-console platform export. Do
not use the superseded September 1 package.

**Validation**

With the matched linked PDI and packaged xclbin, EDF reported one ready edge
device and the test returned:

```text
Mismatches: 0/4096
TEST PASSED
```

An independent success marker confirmed exit status zero.

### 29. JTAG `device program` appeared silent for a linked package

**Symptom**

Programming a linked package produced no CP210 UART output, which initially
looked like a boot failure.

**Cause**

UART visibility is not a reliable completion test during this JTAG sequence.
PLM had loaded the linked PDI and A72 partitions, and Linux later became
reachable through GEM/TCF. A later explicit console test also confirmed that the
UART0 package-pin remap was silent; the source now uses native UART1 instead.

**Solution**

Check all three sources before declaring failure:

- `plm log` for `Boot PDI Load: Done`.
- A72/FPD target state in XSDB.
- Board network and TCF reachability.

Rebuild linked hardware after the UART1 XDC change before expecting CP210 output
from a linked image.

Do not send a second APU-only image after the A72 is already running. That
attempt failed with `XPmApuCore_WakeUp: Status = 7DB` because the core was
already awake.

### 30. `device reset` did not perform an SD boot in JTAG mode

**Symptom**

After `device reset`, there was no UART output and XSDB reported the A72 in
`FPD domain isolation`.

**Cause**

The sampled boot mode remained JTAG (`BOOTMODE: 0x0`), so reset waited for a
JTAG-delivered image instead of reading the SD card.

**Solution**

Use a true power-on reset after setting the physical boot switches, or program
the complete matched `BOOT.BIN` through JTAG. Do not assume `device reset`
changes or re-samples the desired physical boot mode in every board state.

### 31. JTAG programming could stall on a CDO partition

**Symptom**

`device program` stalled while PLM loaded a CDO partition.

**Cause**

The PMC remained in a state that a logical reset did not clear.

**Solution**

Remove all board power, restore power with the card inserted, wait for firmware,
and retry the XSCT loader once. A reset without complete power removal was not
sufficient in this state.

## QEMU and emulation problems

### 32. Direct QEMU aborted without `linux=on`

**Symptom**

```text
Assertion '!info->secure_boot' failed
```

**Cause**

AMD's generic QEMU machine enables secure-boot behavior unless its Linux
property is set, while direct kernel boot bypasses secure Versal firmware boot.

**Solution**

Use:

```text
-M arm-generic-fdt,linux=on
```

### 33. QEMU UART and MMC numbering differed from intuitive numbering

**Symptom**

The SD drive supplied at index 1 appeared as Linux `mmc0`, and the generated
UART console was `ttyAMA0`, not `ttyPS0`.

**Cause**

The standalone VP1902 QEMU model maps PMC debug UARTs before PS UART0/1, and
Linux enumerates the only enabled SD controller as `mmc0`. The generated UART
node uses the PL011 binding.

**Solution**

Use `console=ttyAMA0` and `root=/dev/mmcblk0p2`, and map QEMU serial channels as
documented in `README.md`.

### 34. Direct QEMU lacked PLM-provided clocks and power domains

**Symptom**

UART and SD nodes could not operate normally with their firmware-managed clock
and power references during direct kernel boot.

**Cause**

Direct boot intentionally bypasses PLM and platform-management firmware.

**Solution for exploratory QEMU only**

Use a temporary DT copy with fixed clocks for UART and SD and remove those
nodes' firmware power-domain references. Never apply these QEMU-only changes to
the physical-board DT.

### 35. First-boot services looked stalled under TCG

**Symptom**

`ldconfig.service` and `run-postinsts.service` took several minutes.

**Cause**

TCG software translation is slow.

**Solution**

Mask those services on the kernel command line for a final login-prompt smoke
test. Root mount and normal systemd startup were also tested without masking.

### 36. Linked hardware emulation could not compile the PS model

**Symptoms**

```text
//Empty class
//This device/part is not supported
invalid use of incomplete type 'class ps_wizard_v1_0_7_tlm'
```

**Cause**

Vitis 2025.2 does not provide a usable VP1902 `ps_wizard:1.0` TLM model.
Platform connectivity passes `cfgen`; model generation is the blocker.

**Resolution**

There is no repository fix. Hardware emulation remains unsupported. Direct
QEMU validates only the PS-side software path and is not a replacement for
linked PL emulation. Vitis 2025.2 also does not provide `sw_emu` as a fallback.

### 37. An inactive or unforwarding lab path looked like a board network failure

**Symptom**

Linux showed `end0` as `UP` and `LOWER_UP`, carrier 1, full-duplex 1 Gbps, and
`192.168.1.57/24`, but ARP and ping failed in both directions. TCF was active on
the board but unreachable through the SSH tunnel.

**Cause**

The board-facing lab-host network was not operational. GEM transmitted packets
but received none, and the lab adapter did not observe the board's ARP requests.
The board's `/etc/systemd/network/10-end0.network` file was already selected by
`systemd-networkd`.

**Solution**

Bring up the board-facing host interface at `192.168.1.1/24` before changing
board software. Verify carrier, addresses, ARP, and ping from both endpoints.
Use `NETWORK_BRINGUP_GUIDE.md` for the complete sequence.

**Validation**

In the earlier pre-PHY-reset EDF test, once the host side was running,
`192.168.1.57` responded with zero packet loss,
TCP port 1534 accepted connections, and XSDB TCF access confirmed that
`systemd-networkd` was enabled and active with the persistent `10-end0.network`
configuration. The static-only file hash
`555a2d712401d5eec730a7f513fa3925aaa536e4cf8d2615ec990086d054b4dd`
remained selected with the expected address after a controlled `sudo reboot`
and a true main-power cold cycle. `systemd-networkd` and `tcf-agent.service`
both returned active automatically after that historical cold boot. The later
corrected PHY-reset test used explicit JTAG payload loading; autonomous cold-SD
deployment of the corrected package remains pending.

### 38. GEM1 PHY reset was not controlled by hardware or Linux

**Symptom**

A later recurrence remained after recycling the dedicated host NetworkManager
connection, reseating the cable, cold-cycling the board, and cycling `end0`.
Both PHYs reported 1 Gbps full-duplex carrier, but opposing pings did not
increment either receive counter; the board reported zero received packets.
Linux fallback-scanned MDIO address 3 as `Generic Clause 45 PHY` with PHY ID
`0x00000000`.

**Cause**

The Huins pin map assigns `GEM1_RGMII_RESET` to PMC MIO36. The vendor
reference's high inactive output establishes active-low polarity, but it
incorrectly drove MIO37, which the pin map identifies as test point TP1. The
platform configured MIO36 as an unassigned input, disabled PMC GPIO1, and had no
explicit GEM1 PHY node or `reset-gpios` property.

**Solution**

Enable PMC GPIO1, configure MIO36 as a GPIO output initially high, and describe
the reference-design PHY at MDIO address 7. The PHY node uses
`reset-gpios = <&gpio1 36 GPIO_ACTIVE_LOW>`, asserts reset for 10 ms, and waits
50 ms after deassertion. Apply the PMC GPIO enable after lopper domain pruning;
otherwise lopper removes the provider and leaves a dangling reset phandle.

**Validation**

Vivado 2025.2 successfully rebuilt the pre-synthesis XSA. The build extracts the
XSA's matching `hw_presynth.pdi` rather than reusing an older external PDI. The
rebuilt DTB contains an enabled `xlnx,pmc-gpio-1.0` provider, GEM1
`phy-handle`, PHY address 7, and the expected active-low reset/timing cells.

Bootgen accepted a boot image containing only that pre-synthesis PDI, but the
physical JTAG load failed in PLM with status `0x22390002`. The PDI is a Vitis
link input, not a standalone boot image. A fresh `v++ -l` implementation
produced the complete PDI used for validation.

The complete linked PDI and corrected DT booted EDF with the matching
`6.18.10` kernel. Runtime evidence was:

- `/proc/device-tree` contained the active-low MIO36 `reset-gpios` property.
- PMC GPIO1 reported `okay`.
- MDIO address 7 reported PHY ID `0x01410e40` and driver `Marvell 88E1116R`.
- GEM1 negotiated 1 Gbps full-duplex and both RX and TX counters increased.
- Board-to-host and host-to-board pings completed without loss.
- TCF and `zocl` exposed one ready edge device.
- The matching linked xclbin passed 4096/4096 results with exit code zero.

A common-image `6.12.40` kernel temporarily produced zero XRT devices against
the EDF `6.18.10` rootfs because no matching `zocl` module was available. Keep
the kernel, rootfs, XRT, DT, linked PDI, and xclbin as one artifact set.

## Diagnostic experiments that did not solve the SD problem

The following were useful for narrowing the cause but must not be restored as
platform fixes:

| Experiment | Result |
|---|---|
| Linux SDHCI reset-on-probe source patch | Did not fix card identification; patch was deleted |
| External firmware reset pulse | Did not fix the Linux handoff |
| Delayed reset pulse | Did not fix the Linux handoff |
| No Linux reset | Did not fix the Linux handoff |
| Zero-tap driver correction alone | Reached CMD2 but still failed |
| `no-1-8-v` at 50 MHz | Timed out |
| 3.3 V with `<111>, <48>` phase at 50 MHz | Reached high-speed transition, then timed out |
| SD software reset and SDHCI power toggle | Did not recover an already wedged card |
| `broken-cd` and reduced capability flags | Did not recover an already wedged card |
| Reset without full power removal after a CDO stall | Did not clear PMC state |
| VCK190 split cosimulation DTs | Required missing PMC/PL peers and stalled or asserted |
| Copying only host and xclbin to stock EDF | No matching linked platform was active |
| Mixing common-image `zocl` with EDF | Produced missing-module or invalid-module-format errors |
| Booting EDF userspace with the common-image kernel | Network worked, but `zocl` and `/dev/dri` were absent because kernel modules did not match |
| Treating `hw_presynth.pdi` as a standalone PDI | PLM rejected the physical JTAG load with status `0x22390002` |
| Relying on JTAG `device program` to select the runtime DT | U-Boot sourced stale DDR at `scriptaddr`; explicit payload download and `booti` were required |
| Sending a second APU-only PDI | Failed with wake-up status `0x7DB`; A72 was already awake |

The successful SD runtime combination is DT-only on Linux:

```dts
no-1-8-v;
max-frequency = <25000000>;
clk-phase-sd-hs = <0>, <0>;
```

The U-Boot early host-reset patch remains required.

## Recommended SD validation sequence

Use this sequence for every handoff test:

1. Use the front-panel `PWR SW` to shut down, switch off and unplug the rear ATX
   PSU, and disconnect all USB/JTAG back-power for at least ten seconds. Do not
   operate clock-module `SW6`.
2. Leave the card inserted, reconnect and switch on the ATX PSU, and press the
   front-panel `PWR SW`.
3. Start the patched U-Boot with `u-boot.dtb`.
4. Require `fatload` to return zero.
5. Require the complete `33083904 bytes read` message; a zero return alone is
   not enough evidence.
6. Start the unmodified Vitis 2025.2 kernel with the Linux runtime DT.
7. Require `mmcblk0` and all expected partitions.
8. Reject the run if `error -110`, `error -84`, CID CRC errors, or missing
   partitions appear.

The successful U-Boot state used 3.3 V at 25 MHz with:

```text
ITAP_DELAY=0x00000100
OTAP_DELAY=0x00000040
```

Use XSDB with the A72 stopped for register snapshots. Do not inspect the live
controller through Linux `devmem`.

## Artifact evidence

The following historical package predates the GEM1 PHY reset correction. It was
generated from the UART1-linked XSA and split-console platform export and must
not be mixed with the corrected artifacts.

| Historical artifact | SHA-256 |
|---|---|
| `BOOT.BIN` | `46b66ec59cff67a1f7afbe843ed9fa5b4a4c45c6145c6dd0bd8efaa081531abb` |
| Linux `system.dtb` | `82c0b40ee47e82adbaf9f26e4d903c594a2a21d7d6bdaf17e2d073c0abe9f461` |
| Stock common-image `Image` | `79359c3f0af65cef3dbabab725b156a4b7b1925f781ab42f2f997be70f6dc86c` |
| Packaged `vadd.xclbin` | `1ee7e2d0167195d7b7214209bf604082faaea6cab42f01635a1ac18841435dbc` |
| `simple_vadd` host | `00b461ecde580d7cfd0a07b71b780c8b59fea4640cdaa3d9b6690ef3be498a33` |

The corrected GEM1 reset physical validation used this matched set:

| Corrected artifact | SHA-256 |
|---|---|
| Fully linked PDI | `6b317de3ffc77318d31602945f87b2c560e3975c813e9e35be67580b3dd4a69c` |
| JTAG boot container | `041ff67e6498d6eadf387a87fd3e7a27b32eb77a55a36964b3955cc228d9eaf4` |
| Linux `system.dtb` | `436268f9e5d7ca839f0d7ff707b30d09032183d5a1d63c83e8b7e714a1ef9d8e` |
| Matching EDF `Image` | `74979cce50398475713fbca8301cbc0a8dc35e64af4e8d6e55e31f73b323ca59` |
| Packaged `vadd.xclbin` | `7c5f42a4b1d9086a2e31da92c3dfa5b07f2ee3f8cdbf4b713ea3286a9b9618ad` |
| `simple_vadd` host | `00b461ecde580d7cfd0a07b71b780c8b59fea4640cdaa3d9b6690ef3be498a33` |

Do not mix files between these sets. The corrected JTAG container loaded its
PDI successfully, while explicit kernel/DT downloads and `booti` supplied the
deterministic Linux handoff.

## Remaining limitations

- Linked `hw_emu` is unavailable because the VP1902 PS Wizard TLM model is not
  implemented in Vitis 2025.2.
- VP1902 has no AI Engines; no AIE domain or example can be added.
- The third PL-side DDR SODIMM is outside this base platform.
- EEPROM and remaining board-specific peripheral DT nodes need confirmed wiring
  data before they can be added.
- Exact SW1 settings, QSPI boot, and a clean generic SD-card image boot remain
  to be recorded per board revision.
- Existing EDF cards without the patched U-Boot and conservative Linux SD DT
  may still need the JTAG/hot-reinsert recovery procedure.
- Direct QEMU does not validate PLM, U-Boot, firmware-managed services, PL,
  accelerator kernels, or linked hardware emulation.
- The active project targets the `2MP` device bin. Confirm `2MP` versus `2LP`
  against the exact board OPN before reproducing the design on another board
  revision.

## Maintenance traps

- `platform/generate_platform.py` is the active platform generator used by the
  top-level Makefile. The older `platform/generate_platform.tcl` does not
  implement the custom split-DT BIF flow and must not be substituted for it.
- `sw/prebuilt_linux/dtb_gen/lopper_settings.sh` contains an inactive internal
  Vitis 2025.1 path. The active DT generation path is `sdtgen` in
  `dtb_gen/Makefile`; do not revive the old lopper command without replacing and
  validating that path.
- `sw/prebuilt_linux/user_dts/system-conf.dtsi` contains older root arguments,
  but its include is intentionally commented out. The active chosen node is in
  `system-user.dtsi`, which works around CR-1139794.
- Generated `bd.tcl` boilerplate may say that the design has not been validated.
  That warning describes the generated-script template, not the current
  platform status; implementation, timing, DRC, SD handoff, and `vadd` have all
  been validated separately.

## Related files

- `README.md`: board architecture and validation summary.
- `USAGE.md`: complete build, package, EDF integration, and recovery commands.
- `JTAG_XSDB_GUIDE.md`: JTAG/XSDB board control, SD tests, and recovery decision
  tree.
- `platform/linux.bif`: split U-Boot/Linux DT packaging.
- `sw/prebuilt_linux/user_dts/system-user-uboot.dtsi`: U-Boot control DT.
- `sw/prebuilt_linux/user_dts/system-user.dtsi`: Linux runtime DT.
- `sw/prebuilt_linux/patches/0001-mmc-zynq_sdhci-reset-the-host-controller.patch`:
  retained U-Boot reset fix.
- `hw/xsa_scripts/jtag_edf_rescue.tcl`: EDF JTAG rescue loader.
- `hw/xsa_scripts/huins_vp1902_ddr.xdc`: DDR package constraints.
- `hw/xsa_scripts/huins_vp1902_io.xdc`: EMIO package and I/O-standard constraints.
