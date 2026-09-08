#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2024 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************
# parsing options
set options [dict create {*}$argv]

set xsa_path [dict get $options xsa_path]
set platform_name [dict get $options platform_name]
set platform_out [dict get $options platform_out]
set boot_dir_path [dict get $options boot_dir_path]
set img_dir_path [dict get $options img_dir_path]

set plat_arg [list]
if {$xsa_path ne "" && [file exists $xsa_path]} {
  lappend plat_arg -hw
  lappend plat_arg $xsa_path
} 

platform create -name $platform_name -desc " A base platform targeting the Huins custom Versal Premium xcvp1902 (VP1902) board. This is a site addition for the 2025.2-sislab branch; the hardware configuration was rebuilt from the Huins reference design (ps_wizard + axi_noc, no AIE on Versal Premium Gen1)." {*}$plat_arg -out $platform_out -no-boot-bsp

# NOTE: no AI Engine domain - Versal Premium Gen1 (xcvp1902) has no AIE
domain create -name xrt -proc psv_cortexa72 -os linux -sd-dir $img_dir_path
domain config -boot $boot_dir_path
domain config -generate-bif

domain config -qemu-data $boot_dir_path

platform generate
