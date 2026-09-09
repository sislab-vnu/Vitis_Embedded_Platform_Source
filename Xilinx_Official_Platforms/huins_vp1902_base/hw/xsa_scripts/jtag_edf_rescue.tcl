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

set a72_ready 0
set stop_error ""
for {set attempt 0} {$attempt < 30} {incr attempt} {
  if {![catch {
    targets -set -filter {name =~ "Cortex-A72 #0"}
    stop
  } stop_error]} {
    set a72_ready 1
    break
  }
  after 1000
}
if {!$a72_ready} {
  error "A72-0 did not leave FPD isolation: $stop_error"
}
dow -data $kernel_image 0x20000000
dow -data $initramfs 0x30000000
dow -data $system_dtb 0x00001000

set initramfs_size [file size $initramfs]
puts "Recovery payload is loaded. Hold Ctrl-C in the 115200-baud CP210 terminal."
puts "Then enter:"
puts "setenv bootargs console=ttyAMA0,115200 earlycon=pl011,mmio32,0xFF010000,115200n8 loglevel=8 ignore_loglevel clk_ignore_unused rdinit=/init cma=512M"
puts [format "booti 0x20000000 0x30000000:0x%x 0x1000" $initramfs_size]
after 2000
con
puts "A72-0 is running; interrupt U-Boot now."
