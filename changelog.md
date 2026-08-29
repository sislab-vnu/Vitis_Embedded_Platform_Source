# Change Logs
## 2025.2-sislab
- Site branch `2025.2-sislab` created from upstream `2025.2` for environments where only Vitis 2025.2 is available. Platform sources unchanged; added `AGENTS.md` with agent/build guidance for this branch.
- New site platform `xilinx_zcu106_base` for the ZCU106 board (Zynq UltraScale+ MPSoC, ZynqMP PetaLinux flow), ported from `xilinx_zcu104_base` on branch `2025.1`. PS configuration regenerated from the `xilinx.com:zcu106:part0:2.6` board preset: dual-parallel QSPI, SD1 8-bit SD3.0, 8GB DDR4 SODIMM (dynamic DDR config via SPD, high-address enabled), GPIO0/GPIO1 and I2C0 enabled. Device tree generation uses `createdts -board zcu106-reva` from `device-tree-xlnx` branch `xlnx_rel_v2025.2`. XSA generation verified with Vivado 2025.2.

## 2025.2
- New Platform: `vek385_base`. The new platforms naming convention is updated. Please refer to [UG1701](https://docs.amd.com/r/en-US/ug1701-vitis-accelerated-embedded/Pre-built-Base-Platforms) for details.
- `xilinx_vck190_base_dfx` platform source CED updated to use MBUFGCE to generate clock for AI Engine, aligning with other Versal base platforms.
- Remove `xilinx_zcu104_base` from Xilinx_Official_Platforms after the [deprecation announcement](https://adaptivesupport.amd.com/s/article/000037352?language=en_US). `xilinx_kv260_base` will continue to be supported.

## 2025.1
- `xilinx_vck190_base_dfx` platform updated to use CED to generate hardware platform source.

## 2024.2
- VCK190 base platform updated to use Vivado CED (Customizable Example Design) to generate hardware platform source code. TCL based source code is also provided under HW folder for reference.
- Removed BDC platforms
- All Versal platforms updated the dtb generation scripts to make use of newly introduced system device tree flow. 

## 2023.1

- Removed PetaLinux directory from source code.

## 2022.2

- Removed Petalinux based sw components generation from platform creation.

## 2022.1

- VCK190 Base Platform clock frequencies updated to match the fraction of AI Engine clock frequency.
- Added VCK190 Base DFX Platform
- All platforms updated the dtb generation scripts to make use of newly introduced `createdts` command.
- Updated top makefile to use pre-built common image by default.

## 2021.1

- VCK190 Base Platform enables ECC on DDR and LPDDR; constraints become concise.
- MPSoC base platforms increased CMA size to 1536M. All Vitis-AI models can run with this CMA size.
- Embedded platform creation flow gets simplified: Device Tree Generator can automatically generate a ZOCL node; XSCT can generate BIF files. Base platform source files are reduced.

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2025 Advanced Micro Devices, Inc.</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>