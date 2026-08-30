# Huins VP1902 Base Platform (custom board)

***Version: 2025.2 (202520_1)*** · **Status: XSA builds (pre-synth + hw_emu verified on Vivado 2025.2)**

Site addition on the `2025.2-sislab` branch: an extensible Vitis base platform for the
custom Huins board built around the **Versal Premium `xcvp1902`** device. Ported from
`xilinx_vck190_base` (the closest platform in this repository: Versal Gen1, AI Engine,
same extensible feature set and PetaLinux flow).

## Target device

| Type | Value |
|---|---|
| Device | `xcvp1902-vsva6865-2MP-e-S` — **confirm 2MP vs 2LP bin with Huins** (OPN `XCVP1902-2MSEVSVA6865`) |
| Platform name | `huins_vp1902_base_202520_1` |
| Vitis | 2025.2 |
| Common image | `xilinx-versal-common-v2025.2` (shared with all Versal platforms here) |

## ⚠️ Open hardware items (blocking XSA build)

Verified on this workstation's Vivado 2025.2 (empirically, per-IP):

| IP | on `xcvp1902-vsva6865-2MP-e-S` |
|---|---|
| `ps_wizard:1.0` | **OK** — use this instead of `versal_cips` (CIPS 3.4 rejects xcvp1902) |
| `axi_noc:1.1` (Gen1 NOC) | **OK** |
| `axi_noc2:1.1`, `ai_engine:2.0` | NOT supported (Gen2-only) |

Key hardware facts for the port:
- **Versal Premium Gen1 has no AI Engines** — the vck190 `ai_engine` cell and its
  clocks must be dropped when regenerating the design.
- No CED exists for vpk180/xcvp1902 (`ext_platform` and `versal_common_platform`
  CEDs are board-driven: vck190/vek280/vek385/vrk160/165 only).

Board facts extracted from `huins_mfp-vp1902_userguide.pdf` (Huins MFP-VP1902-S):

| Item | Value |
|---|---|
| FPGA | `XCVP1902-2MSEVSVA6865` — **confirmed** by Huins reference BD (`vp1902s_top.tcl`, part `xcvp1902-vsva6865-2MP-e-S`) |
| PS DDR4 | 2× SODIMM 32GB, DDR4-2666 (SODIMM 0/1, via PS DDRMC) |
| PL DDR4 | 1× SODIMM 32GB (SODIMM 2, PL area — out of base-platform scope) |
| DDR4 MIG @NoC | DDR4 SDRAM, SoDIMM, bin DDR4-3200AA(22-22-22), sys clock 200 MHz; MC0 = banks 821-823, MC1 = banks 700-702 (Advanced I/O Planner) |
| QSPI | dual-parallel flash ×2, PMC MIO 0..12 |
| USB | USB 2.0 (ULPI), PMC MIO 13..25 |
| SD | microSD 3.0: `PMC_SD1_30AD_PERIPHERAL` MIO 26:36, `4Bit_autodir`, `SD_3.0_AUTODIR`, high_speed |
| Ethernet | `PS_ENET1_PERIPHERAL` RGMII MIO 38:49; `PS_ENET1_MDIO` on EMIO (XIO BM13/BL13); GEM1 ref clk 125 MHz |
| USB | `PS_USB3_PERIPHERAL` on PMC MIO 13:25 (USB-2.0 ULPI PHY, no GT) |
| UART0/1, I2C0/1 | **EMIO** (UART 115200; I2C0 XIO BM17/BM18, I2C1 BL16/BM16) |
| 
| PL clocks (ps_wizard) | PL0 100 / PL1 300 / PL2 200 / PL3 125 MHz; NOC ref 1000 MHz |
| DDR4 NoC | `axi_noc:1.1`, DDR4_SDRAM, `SODIMMs`, `DDR4-3200AA(22-22-22)`, RANK 2, NUM_MC 2 / NUM_MCP 2, NUM_SI 10, NUM_CLKS 12; DDR sys clocks are **external ports** `C0_DDR4_SYS`/`C1_DDR4_SYS` (board 200 MHz OSCs) |
| Boot | JTAG/QSPI/SD selectable (SW1) |
| AI Engine | none (Versal Premium Gen1) |

⚠️ **EMIO console caveat**: UART0/1 route through EMIO → PL XIO pins. With a
pre-synth (PL-empty) platform there is **no serial console until a PL bitstream is
loaded**; networking via GEM1 (MIO) is unaffected. Use a post-impl platform if
early-console visibility is required.

Open items (blocking XSA build):
1. **Rebuild the BD manually** (no CED): `ps_wizard` (PS/PMC config) + `axi_noc`
   (Master_NoC + 2× DDR4 MC per the table above) + `clk_wiz` + interconnects +
   `axi_vip` kernel-ctrl, mirroring `xilinx_vck190_base` minus AIE. ps_wizard
   accepts classic Versal PMC/PS keys (verified: `PMC_REF_CLK_FREQMHZ`); invalid
   keys are silently ignored — verify by read-back. The vck190 `dr.bd.tcl` CIPS
   dict is the key-value source; PMC ref clock frequency not stated in the guide
   (TBD — probe or confirm with Huins).
2. **Device tree**: `createdts`/`sdtgen` uses `-board_dts versal-vpk180-reva`
   (closest same-die eval board; the VPK180 hosts the VP1902). Replace with a Huins
   board DTS when available, or prune VPK180-specific nodes via
   `sw/prebuilt_linux/user_dts/system-user.dtsi`.
3. **`hw/xsa_scripts/pfm_decls.tcl`**: PFM sptags reference the VC1902 NOC cells —
   update to match the regenerated design.

The TODO markers in `hw/xsa_scripts/*.tcl` mark every spot that needs work.

## Build (once the above is resolved)

Identical to the other PetaLinux-flow platforms:

```bash
source <Vitis_install>/Vitis/2025.2/settings64.sh
make all PREBUILT_LINUX_PATH=/opt/xilinx/platform/xilinx-versal-common-v2025.2
```

Output: `platform_repo/huins_vp1902_base_202520_1/export/…`.

## Test the Platform

Once the platform builds, use the [Vitis Template](https://github.com/Xilinx/vitis_templates/)
to build a `vadd` application and validate on the Huins board.
