#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************
.EXPORT_ALL_VARIABLES:

#tools
VIVADO  = $(XILINX_VIVADO)/bin/vivado
DTC     = $(XILINX_VITIS)/bin/dtc
BOOTGEN = $(XILINX_VITIS)/bin/bootgen
XSCT    = $(XILINX_VITIS)/bin/xsct

#platform specific
PLATFORM = huins_vp1902_base
CPU_ARCH = a72
CORE     = psv_cortexa72_0

#versioning
VERSION          ?= 202520_1
VER              ?= 202520.1

#common
TOP_DIR         ?= $(shell readlink -f .)

#hw related
XSA_DIR         ?= $(TOP_DIR)/hw/build
XSA             ?= $(XSA_DIR)/hw.xsa
RP_XSA          ?= $(XSA_DIR)/rp/rp.xsa
STATIC_XSA      ?= $(XSA_DIR)/static.xsa
HW_EMU_XSA      ?= $(XSA_DIR)/hw_emu/hw_emu.xsa
PRE_SYNTH       ?= TRUE

#sw related
SW_DIR           = $(TOP_DIR)/sw/build
BOOT_DIR         = $(SW_DIR)/platform/boot
IMAGE_DIR        = $(SW_DIR)/platform/image
UBOOT_DTB_FILE   = $(BOOT_DIR)/u-boot.dtb
LINUX_DTB_FILE   = $(IMAGE_DIR)/system.dtb
DTB_FILE         = $(LINUX_DTB_FILE)
BOOT_IMAGE       = $(BOOT_DIR)/BOOT.BIN
SW_FILES         = $(IMAGE_DIR)/boot.scr $(BOOT_DIR)/u-boot.elf $(BOOT_DIR)/bl31.elf
BOOT_FILES       = u-boot.elf bl31.elf

#platform related
PLATFORM_NAME    = $(PLATFORM)_$(VERSION)
PLATFORM_SW_SRC  = $(TOP_DIR)/platform
PLATFORM_BIF     = $(PLATFORM_SW_SRC)/linux.bif
PLATFORM_DIR      = $(TOP_DIR)/platform_repo

#flow related
ifneq ($(wildcard $(TOP_DIR)/xilinx-versal-common-v2025.2),)
  PREBUILT_LINUX_PATH ?= $(TOP_DIR)/xilinx-versal-common-v2025.2
else
  PREBUILT_LINUX_PATH ?= /opt/xilinx/platform/xilinx-versal-common-v2025.2
endif

# The 2025.2 common image can be replaced with a platform-specific U-Boot.
UBOOT_ELF ?= $(PREBUILT_LINUX_PATH)/u-boot.elf

# Keep user-supplied relative paths valid in recursive hardware/software builds.
ifneq ($(origin XSA),file)
  ifneq ($(wildcard $(XSA)),)
    override XSA := $(realpath $(XSA))
  endif
endif
ifneq ($(origin PREBUILT_LINUX_PATH),file)
  ifneq ($(wildcard $(PREBUILT_LINUX_PATH)),)
    override PREBUILT_LINUX_PATH := $(realpath $(PREBUILT_LINUX_PATH))
  endif
endif
ifneq ($(origin UBOOT_ELF),file)
  ifneq ($(wildcard $(UBOOT_ELF)),)
    override UBOOT_ELF := $(realpath $(UBOOT_ELF))
  endif
endif

#common targets
check-vitis:
ifeq ($(XILINX_VITIS),)
	$(error ERROR: 'XILINX_VITIS' variable not set, please set correctly and rerun)
endif

check-prebuilt:
ifeq (,$(wildcard $(PREBUILT_LINUX_PATH)))
	$(info )
	$(info PREBUILT common images cannot be found at $(PREBUILT_LINUX_PATH))
	$(info If PREBUILT common images are present in another directory, Please specify the path to images as follows :)
	$(info make all PREBUILT_LINUX_PATH=/path/to/boot_files/dir)
	$(info else)
	$(info Please download PREBUILT common images from https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-platforms.html and extract them to /opt/xilinx/platform)
	$(error )
else
	$(info Found Platform Images at $(PREBUILT_LINUX_PATH))
endif
ifeq ($(PREBUILT_LINUX_PATH),)
	$(error ERROR: 'PREBUILT_LINUX_PATH' is not accesible, please set this flag to path containing common software)
endif
