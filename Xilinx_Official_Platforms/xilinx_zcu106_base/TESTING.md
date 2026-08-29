# xilinx_zcu106_base — Port & Verification Findings

**Branch**: `2025.2-sislab` (site branch cut from upstream `2025.2`) · platform commit `f9c1432`
**Host toolchain**: Vivado/Vitis 2025.2 (`/home/tools/xilinx/2025.2`) · Linux only
**Board**: ZCU106 Rev1.0 at `172.16.10.34` (user `amd-edf`), running the AMD EDF image

---

## 1. Status summary

| Item | Status |
|---|---|
| Platform port (2025.1 zcu104 → 2025.2 zcu106) | Done, committed |
| XSA build on Vivado 2025.2 | PASS |
| Full platform build (`make all`) with common image | PASS — `.xpfm` produced, `platforminfo` correct |
| Static DTB comparison vs running EDF DTB | PASS |
| Boot-stack swap on real board | **FAILED** — board did not return; recovery path prepared |
| QEMU smoke test (kernel + our DTB) | PASS (with QEMU-specific memory adaptation) |
| QEMU FSBL/U-Boot boot-chain emulation | Not reachable with manual QEMU (needs Vitis launch machinery) |
| `pyxrt` Python binding | Built + import-verified; pending on-board install |

---

## 2. Platform port (what changed and why)

Source: `xilinx_zcu104_base` @ branch `2025.1` → `xilinx_zcu106_base`.

Both boards use the same part (`xczu7ev-ffvc1156-2-e`); all differences are board-level PS configuration.

### 2.1 PS configuration (`hw/xsa_scripts/dr.bd.tcl`)

The zcu104 script carries a full generated `ps_e` CONFIG dict (zcu104 preset + Vivado-derived values + platform intent). Hand-editing it for zcu106 would leave stale MIO pin values, so the dict was **regenerated in Vivado 2025.2**:

1. Apply the `xilinx.com:zcu106:part0:2.6` board preset (parsed from
   `/home/tools/xilinx/2025.2/data/xhub/boards/XilinxBoardStore/boards/Xilinx/zcu106/2.6/preset.xml`;
   note `apply_board_preset` does not exist as a Tcl command in Vivado 2025.2).
2. Overlay platform-intent keys from the zcu104 dict — but only where the zcu104
   *preset* agrees with the zcu104 *dict*. This preserves deliberate platform
   overrides (`PSU__USE__M_AXI_GP1 0→0, GP2 1`, DDR QoS, data widths) while
   dropping 15 keys where the zcu106 preset supersedes stale zcu104 board values.
3. Dump the IP-resolved result and splice it back into `dr.bd.tcl`.

Key zcu104 → zcu106 PS differences (all verified in the built XSA):

| Parameter | zcu104 | zcu106 |
|---|---|---|
| QSPI | Single, MIO 0..5 | **Dual Parallel**, MIO 0..12, FBCLK MIO 6 |
| SD1 | 4-bit, SD 2.0, MIO 46..51 | **8-bit, SD 3.0**, MIO 39..51, WP/POW |
| DDR | 2GB, static config | **8GB SODIMM**, `PSU_DYNAMIC_DDR_CONFIG_EN=1` (SPD read at boot), high-address enabled |
| GPIO0/GPIO1 MIO | disabled | enabled |
| I2C0 | disabled | enabled (MIO 14..15) |
| PSS ref clock | 33.333333 MHz | 33.330 MHz |

### 2.2 Other files

| File | Change |
|---|---|
| `platform.mk` | `PLATFORM=xilinx_zcu106_base`, `BOARD=zcu106-reva`, `VERSION=202520_1`, `VER=202520.1`, prebuilt path `v2025.2`; fixed upstream `zynpmp` typo |
| `hw/xsa_scripts/project.tcl` | board part `xilinx.com:zcu106:part0:*` |
| `sw/prebuilt_linux/Makefile` | `createdts -git-branch xlnx_rel_v2025.2` (board name comes from `platform.mk`: `zcu106-reva`) |
| `platform/generate_platform.tcl` | platform description updated to ZCU106/8GB |
| `README.md`, `hw/README.hw` | rewritten for ZCU106; XRT tag `202520.2.20.0_Petalinux` |
| `.gitignore` (new, platform root) | `platform_repo/`, `sw/build/`, `hw/build/`, vivado artifacts |

Internal versioning note: Vitis 2025.2 maps to `202520_1` / `202520.1` (not `_2`) — do not "fix".

---

## 3. Build verification (host)

```bash
source /home/tools/xilinx/2025.2/Vitis/settings64.sh
cd Xilinx_Official_Platforms/xilinx_zcu106_base
make all PREBUILT_LINUX_PATH=/home/tools/xilinx/prebuilt/xilinx-zynqmp-common-v2025.2
```

- XSA generation ~12 min (pre-synth). Output `hw/build/hw.xsa` embeds the zcu106 board files (`board/2.6/…`).
- Full build produces `platform_repo/xilinx_zcu106_base_202520_1/export/…/xilinx_zcu106_base_202520_1.xpfm`.
- `platforminfo` confirms: ZCU106/8GB description, `202520.1`, extensible.
- Built XSA `.xci` verified for: Dual-Parallel QSPI, UDIMM, DDR4_2133P @1067 MHz,
  `PSU_DYNAMIC_DDR_CONFIG_EN=1`, SD1 8-bit, GPIO0/I2C0, correct M_AXI enables.

Device tree was generated with `createdts -board zcu106-reva`
(device-tree-xlnx `xlnx_rel_v2025.2`; `zcu106-reva.dtsi` confirmed present in that branch).

---

## 4. Board testing (172.16.10.34)

### 4.1 Board environment (verified over SSH)

- AMD EDF image (`ID=amd-edf`), kernel `6.18.10-xilinx`, DT model `ZynqMP ZCU106 Rev1.0`
- Boot chain: `boot.bin` (FSBL+PMU+U-Boot) → U-Boot EFI → systemd-boot (`/efi/loader/`) → `/efi/Image` via EFI stub; kernel DTB = U-Boot control FDT
- SD (mmcblk0): p1 `/efi` (boot files), p2 `/storage`, rootfs ~12 GB (`root=PARTUUID=35bb9554-6997-4265-8ee0-ef5c72f03ef3`)
- RAM visible: **3.8 GiB** (static 4GB map — our dynamic-DDR FSBL is expected to change this to ~8GB)
- `fpgautil` present; `xbutil`/`xmutil` absent; `CONFIG_KEXEC=y` but no `kexec` userspace binary

### 4.2 Static DTB comparison (no reboot) — PASS

Decompiled the running EDF DTB (`/sys/firmware/fdt`) and compared with our generated `system.dtb`:

- All PS peripherals match: dual QSPI (`is-dual`), SD1, GEM3, UART (stdout UART0), I2C0, GPIO
- Ours adds the Vitis-platform nodes: `zocl` (`zyxclmm_drm`) + `axi_intc@80020000`
- CMA: EDF uses a DTB reserved-memory pool; ours uses `cma=1536M` in bootargs (platform convention)
- Static memory node ≈ 4GB in both (dynamic DDR / U-Boot fixup handles the rest at boot)

### 4.3 Boot-stack swap — FAILED (board down, recovery prepared)

Deployed to `/efi`:
- `boot.bin` ← our BOOT.BIN (our FSBL [dynamic-DDR] + PMUFW + BL31 + our `system.dtb` @0x100000 + U-Boot; no bitstream — pre-synth platform). Original backed up as `boot.bin.edf-orig`
- `system-vitis.dtb` — our DTB with `root=PARTUUID=35bb9554-…` bootargs (adapted to the EDF card layout; the repo dtsi keeps `root=/dev/mmcblk0p2`, correct for the standard Vitis SD layout)
- `extlinux/extlinux.conf` — boots the existing EDF `/Image` with our DTB
- `RESTORE.txt` — recovery instructions (restore `boot.bin.edf-orig`)

Result: board never came back (SSH + ping dead > 7 min). **Recovery requires physical access** (restore backup per `/efi/RESTORE.txt`).

Suspected causes, most likely first:
1. **FSBL dynamic-DDR**: `PSU_DYNAMIC_DDR_CONFIG_EN=1` reads the SODIMM SPD over I2C0 at boot; if that read fails, DRAM init breaks. The running EDF stack appears to boot this board with static DDR config.
2. U-Boot boot-path mismatch (PetaLinux/common-image U-Boot vs EDF's EFI flow) — would be visible on serial.
3. Kernel/DTB — least likely (structurally consistent; boots in QEMU).

**Required next step**: capture the serial console (USB-UART) during a retry to pinpoint the hang.

---

## 5. QEMU validation (host)

What works — direct kernel boot (`-M xlnx-zcu102`, Vitis QEMU at
`$XILINX_VITIS/data/emulation/qemu/comp/qemu/sysroots/x86_64-petalinux-linux/usr/bin`):

```bash
qemu-system-aarch64 -M xlnx-zcu102 -nographic -m 2G \
  -kernel Image -dtb sys_qemu.dtb \
  -append "earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/mmcblk1 rw rootwait" \
  -drive file=rootfs4g.img,if=sd,format=raw,index=1
```

- Kernel 6.12.40 (common image) + our DTB: `Machine model: ZynqMP ZCU106 RevA`, earlycon/UART0, GIC/timers OK, ~40 drivers defer *cleanly*, reaches root-device wait
- The only DTB adaptation: `/memory@0/reg` reduced to the low 2GB via `fdtput` — QEMU does not model the ZynqMP high-DDR window at `0x8_0000_0000` that the platform correctly declares for 8GB. The repo DTB is unchanged
- Driver deferrals are expected: no ATF/PMUFW in this mode, so zynqmp-firmware clocks never register

What QEMU cannot test:
- **FSBL** — the Vitis ZynqMP emulation flow skips FSBL entirely
- BL31 + U-Boot chain via `-M arm-generic-fdt` — needs the official Vitis launch machinery (PMU instance + cosim remote-port endpoint); manual pairing stalls on `qemu-rport-_pmu@0` / `qemu-rport-_amba@0_cosim@0` socket handshakes

Net: QEMU validates kernel+DTB; the FSBL/DDR question can only be answered on hardware (with serial logs).

---

## 6. XRT Python bindings (`pyxrt`)

The 2025.2 ZynqMP common image already ships XRT 202520.2.20.0 + `zocl`
(built for machine `xlnx_zynqmp_zcu106_reva`, kernel `6.12.40-xilinx-g31626ef92ff1`) and OpenCL —
**no image rebuild needed**. The only missing piece was `pyxrt`, which was built out-of-tree:

- Source: XRT tag `202520.2.20.0_Petalinux` (exact version match)
- `pyxrt` = pybind11 module (`src/python/pybind11/src/pyxrt.cpp`), links `libxrt_coreutil.so.2` + `libuuid` only
- Built with the Yocto SDK cross-g++ against the sysroot installed from the common image's `sdk.sh`
  (`/home/admin/sysroot-zcu106`), pybind11 2.13.6 headers:

```bash
source /home/admin/sysroot-zcu106/environment-setup-cortexa72-cortexa53-amd-linux
$CXX -std=c++17 -shared -fPIC -fvisibility=hidden -O2 \
  -I$SDKTARGETSYSROOT/usr/include/python3.12 \
  -I/tmp/opencode/pybind11-2.13.6/include \
  pyxrt.cpp -o pyxrt.cpython-312-aarch64-linux-gnu.so \
  -L$SDKTARGETSYSROOT/usr/lib -lxrt_coreutil -luuid -lpthread
```

- Verified: `import pyxrt` succeeds under `qemu-aarch64 -L <sysroot>` with target Python 3.12
- Artifact: `/tmp/opencode/XRT/src/python/pybind11/src/pyxrt.cpython-312-aarch64-linux-gnu.so`
- On-board install: copy to `/usr/lib/python3.12/site-packages/`
- Caveats: cpython-312 ABI (EDF rootfs Python version must be 3.12 — unverified while board is down); `zocl` must be loaded for real device access

---

## 7. Open items

1. **Restore the board** (`/efi/boot.bin.edf-orig` → `boot.bin`, per `/efi/RESTORE.txt`)
2. Capture serial console during a boot retry → confirm whether the hang is in FSBL (dynamic DDR) or U-Boot
3. If dynamic DDR is the culprit: prepare a static-8GB DDR variant (`PSU_DYNAMIC_DDR_CONFIG_EN=0` + static training parameters) and retry the swap
4. Install `pyxrt` on the board; verify `python3 -c "import pyxrt; pyxrt.device(0)"` with `zocl` loaded
5. End-to-end application test: vadd via `v++` (`-t hw`) against the platform, load xclbin with `fpgautil`, run Python host
6. Commit this document

## 8. Artifact map (host)

| Path | Contents |
|---|---|
| `Xilinx_Official_Platforms/xilinx_zcu106_base/` | platform sources (committed) |
| `platform_repo/xilinx_zcu106_base_202520_1/export/` | built platform (`.xpfm`) |
| `/tmp/opencode/qemu_run/` | QEMU boot scripts + logs (`qemu_kernel.sh`, `arm.log`) |
| `/tmp/opencode/XRT/` + `pyxrt…so` | XRT source + built Python module |
| `/home/admin/sysroot-zcu106/` | Yocto SDK sysroot (for cross-builds) |
| `/home/tools/xilinx/prebuilt/xilinx-zynqmp-common-v2025.2/` | common image (Image, rootfs, boot files, sdk.sh) |
