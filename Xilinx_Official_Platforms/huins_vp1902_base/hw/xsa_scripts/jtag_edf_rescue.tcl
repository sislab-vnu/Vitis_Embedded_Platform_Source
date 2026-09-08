#******************************************************************************
# Copyright (C) 2026 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************

if {$argc != 5} {
  puts "Usage: xsct jtag_edf_rescue.tcl <hw_server-url> <BOOT.BIN> <Image> <initramfs.cpio.gz> <system.dtb>"
  exit 1
}

set hw_server_url [lindex $argv 0]
set boot_bin [file normalize [lindex $argv 1]]
set kernel_image [file normalize [lindex $argv 2]]
set initramfs [file normalize [lindex $argv 3]]
set system_dtb [file normalize [lindex $argv 4]]

foreach path [list $boot_bin $kernel_image $initramfs $system_dtb] {
  if {![file isfile $path]} {
    error "Required recovery file does not exist: $path"
  }
}

connect -url $hw_server_url
targets -set -filter {name == "Versal xcvp1902"}
device reset
after 3000
device program $boot_bin
after 5000

targets -set -filter {name =~ "Cortex-A72 #0"}
stop
dow -data $kernel_image 0x20000000
dow -data $initramfs 0x30000000
dow -data $system_dtb 0x00001000
con

set initramfs_size [file size $initramfs]
puts "Recovery payload is loaded and A72-0 is running."
puts "Open the CP210 UART at 115200 baud and interrupt U-Boot with Ctrl-C."
puts "Then enter:"
puts "setenv bootargs console=ttyAMA0 earlycon=pl011,mmio32,0xFF000000,115200n8 loglevel=8 ignore_loglevel clk_ignore_unused rdinit=/init cma=512M"
puts [format "booti 0x20000000 0x30000000:0x%x 0x1000" $initramfs_size]
