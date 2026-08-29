# AGENTS.md

## What this repo is

Source for recreating AMD Vitis embedded base platforms. Content is Makefiles + Vivado TCL + Python packaging scripts — no application code, no test suite, no CI, no lint/format config. The only verification is building a platform with Vitis installed (expensive, Linux only, needs licenses).

## Branch context (sislab)

- Work happens on `2025.2-sislab`, a site branch cut from upstream `2025.2`, because only Vitis 2025.2 is installed locally. Do not pull in content from later release branches (`2026.1`, `master`): the platform set and docs differ.
- Upstream tracks each release on its own branch (`2019.2` ... `2026.1`, plus `master`). Keep site changes on `2025.2-sislab`; upstream-style release changes would go on the matching version branch.
- Platform set on this branch — EDF flow: `vek385_base`, `vek385_base_reva`; PetaLinux flow: `xilinx_kv260_base`, `xilinx_vck190_base`, `xilinx_vck190_base_dfx`, `xilinx_vek280_base`, `xilinx_vmk180_base`, `xilinx_zcu106_base`. Platforms like `vck190_base`, `kv260_base`, `vrk160_base` (no prefix) only exist in later releases; `xilinx_vmk180_base` only exists up to here.
- `xilinx_zcu106_base` is a site addition: ported from `xilinx_zcu104_base` (branch `2025.1`) for the ZCU106 board. Its `hw/xsa_scripts/dr.bd.tcl` PS dict was regenerated from the `xilinx.com:zcu106:part0:2.6` board preset — key differences vs zcu104: dual-parallel QSPI (MIO 0..12), SD1 8-bit SD3.0 (MIO 39..51), 8GB DDR4 SODIMM with `PSU_DYNAMIC_DDR_CONFIG_EN=1` (SPD-configured at boot) and DDR high-address enabled, GPIO0/GPIO1 + I2C0 enabled, PSS ref clock 33.330 MHz. DTG board name is `zcu106-reva` (`createdts -board`). XSA build verified on Vivado 2025.2.

## Internal versioning gotcha (critical)

All `platform.mk` files on this branch use `VERSION ?= 202520_1` and `VER ?= 202520.1` — the internal scheme maps Vitis 2025.2 → `202520_1`, not `202520_2`. Built platform names come out as e.g. `xilinx_vck190_base_202520_1`. Do not "fix" these to `_2`; the platform name must match the released platform.

## Two platform flows

All platforms live under `Xilinx_Official_Platforms/<name>/` with a top `Makefile` that includes `platform.mk`, and targets: `all`, `xsa`, `linux`, `platform`, `clean`, `help`.

- **EDF flow** (no `sw/` dir): `vek385_base`, `vek385_base_reva`. `make all` only builds the XSA (`hw/xsa_scripts/xsa.tcl` in batch Vivado) then packages via `vitis -s platform/generate_platform.py`. Software comes from pre-built EDF images — there is no sw build step. Hardware is generated from a Vivado CED; the TCL equivalent is `hw/xsa_scripts/reference_bd.tcl` (plus `custom_platform.tcl`). Edit `bd.tcl`/`update_bd.tcl`, not a checked-in .xpr (none exists).
- **PetaLinux flow** (`xilinx_` prefix, `sw/` dir): `xilinx_kv260_base`, `xilinx_vck190_base`, `xilinx_vck190_base_dfx`, `xilinx_vek280_base`, `xilinx_vmk180_base`. `make all` = XSA → sw artifacts (device tree via `sdtgen` + prebuilt boot files) → platform packaging. All of these append the version to `PLATFORM_NAME` (`$(PLATFORM)_$(VERSION)`).
- `xilinx_kv260_base` runs on ZynqMP (`zynqmp` common image, a53); all other platforms here are Versal (`versal` common image).

## Building

```bash
source <Vitis_install>/Vitis/2025.2/settings64.sh   # required; make errors without XILINX_VITIS
cd Xilinx_Official_Platforms/<platform>
make all                                            # pre-synth XSA + prebuilt Linux
make all PRE_SYNTH=FALSE                            # post-impl XSA — REQUIRED for the DFX platform
make linux XSA=/path/to.xsa && make platform        # reuse an existing XSA
```

- `PREBUILT_LINUX_PATH` defaults to `/opt/xilinx/platform/xilinx-<arch>-common-v2025.2`; arch is per-platform (`versal` or `zynqmp`). A common-image copy dropped inside the platform dir is picked up automatically.
- Output lands in `platform_repo/<platform>/export/<platform>/`; success check is `find . -name "*.xpfm"`.
- `platform_repo/`, `hw/build/`, `sw/build/`, `vivado*`, `.Xil/` are generated artifacts — never commit them.

## Gotchas

- `sw/prebuilt_linux/dtb_gen/lopper_settings.sh` hard-codes an internal `/proj/xbuilds/2025.1_daily_latest/...` Vitis path and its lopper invocation is commented out; the active DTB path is `sdtgen` in `dtb_gen/Makefile`. Device trees use the system device tree flow (`user_dts/system-user.dtsi` is the user override).
- Versal XSA always contains a pre-synth PDI even with `PRE_SYNTH=FALSE`; DFX also builds a reconfigurable-partition XSA (`RP_XSA`).
- README.md and changelog.md are per-branch: this branch's README already states Vitis 2025.2 and has no platform table. Don't copy 2026.1-era doc content (EDF platform lists, naming-convention tables) into it.
