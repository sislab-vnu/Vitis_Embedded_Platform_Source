#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************
CWD = $(shell readlink -f .)
TOP_DIR = $(CWD)/../../
include $(TOP_DIR)/platform.mk

SYSTEM_USER_DTSI       = $(CWD)/user_dts/system-user.dtsi
UBOOT_SYSTEM_USER_DTSI = $(CWD)/user_dts/system-user-uboot.dtsi
ROOTFS_NETWORK_CONFIG  = $(CWD)/rootfs_overlay/etc/systemd/network/10-end0.network
ROOTFS_GETTY_UNIT      = $(CWD)/rootfs_overlay/etc/systemd/system/huins-uart-getty.service
ROOTFS_PREPARE_SCRIPT  = $(CWD)/prepare_rootfs.sh
#SYSTEM_CONF_DTS  = $(CWD)/user_dts/system-conf.dtsi
PDI_FILE         = $(SW_DIR)/hw.pdi
HW_PDI          ?= $(dir $(XSA))hw.pdi
HW_PDI_MODE     ?= $(dir $(XSA))hw.pdi.mode
DTB_PATH         = $(CWD)/dtb_gen
DTB_GEN_SOURCES  = $(DTB_PATH)/Makefile \
	$(DTB_PATH)/system-linux-wrapper.dts \
	$(CWD)/user_dts/system-user-post.dtsi


.PHONY: check-vitis check-prebuilt all sw_comp dtb bootimage clean

$(XSA):
	$(MAKE) -C $(TOP_DIR) xsa

dtb: $(UBOOT_DTB_FILE) $(LINUX_DTB_FILE)

$(UBOOT_DTB_FILE): $(XSA) $(UBOOT_SYSTEM_USER_DTSI) $(DTB_PATH)/Makefile | check-vitis
	$(info "Generating SW Artifacts...")
	@if [ ! -d $(BOOT_DIR) ]; then mkdir -p $(BOOT_DIR); fi
	$(info "U-Boot DTB generation started using sdtgen+lopper")

	$(MAKE) -C dtb_gen all XSA="$(XSA)" \
		USER_DTSI="$(UBOOT_SYSTEM_USER_DTSI)" \
		SDT_OUT="sdt_out_uboot" DTB_OUT="system-uboot.dtb" \
		DOMAIN_DTS="system-domain-uboot.dts" POST_DTSI=

	@if [ ! -f $(DTB_PATH)/system-uboot.dtb ]; then echo -e "ERROR: U-Boot device tree generation failed\n"; exit 1; fi
	cp $(DTB_PATH)/system-uboot.dtb $(UBOOT_DTB_FILE) -v

$(LINUX_DTB_FILE): $(XSA) $(SYSTEM_USER_DTSI) $(DTB_GEN_SOURCES) | check-vitis
	$(info "Generating SW Artifacts...")
	@if [ ! -d $(IMAGE_DIR) ]; then mkdir -p $(IMAGE_DIR); fi
	$(info "Linux DTB generation started using sdtgen+lopper")

	$(MAKE) -C dtb_gen all XSA="$(XSA)" \
		USER_DTSI="$(SYSTEM_USER_DTSI)" \
		SDT_OUT="sdt_out_linux" DTB_OUT="system-linux.dtb" \
		DOMAIN_DTS="system-domain-linux.dts"

	@if [ ! -f $(DTB_PATH)/system-linux.dtb ]; then echo -e "ERROR: Linux device tree generation failed\n"; exit 1; fi
	cp $(DTB_PATH)/system-linux.dtb $(LINUX_DTB_FILE) -v

sw_comp: $(SW_FILES) $(ROOTFS_IMAGE)

$(SW_FILES): $(UBOOT_DTB_FILE) $(LINUX_DTB_FILE) $(UBOOT_ELF)
	mkdir -p $(IMAGE_DIR)
	cp -f $(PREBUILT_LINUX_PATH)/boot.scr ${IMAGE_DIR}/boot.scr
	cp -f $(UBOOT_ELF) $(BOOT_DIR)/u-boot.elf
	$(foreach BOOT_FILE,$(filter-out u-boot.elf,$(BOOT_FILES)),cp -f $(PREBUILT_LINUX_PATH)/$(BOOT_FILE) $(BOOT_DIR) ;)

$(ROOTFS_IMAGE): $(PREBUILT_LINUX_PATH)/rootfs.ext4 $(ROOTFS_NETWORK_CONFIG) $(ROOTFS_GETTY_UNIT) $(ROOTFS_PREPARE_SCRIPT)
	$(ROOTFS_PREPARE_SCRIPT) $(PREBUILT_LINUX_PATH)/rootfs.ext4 $(ROOTFS_IMAGE)

all: check-vitis check-prebuilt $(SW_FILES) $(UBOOT_DTB_FILE) $(LINUX_DTB_FILE) $(ROOTFS_IMAGE)

$(PDI_FILE): $(XSA)
	mkdir -p $(SW_DIR)
	@if [ ! -f "$(HW_PDI)" ]; then echo "ERROR: Post-implementation PDI not found at $(HW_PDI)"; exit 1; fi
	cp -f $(HW_PDI) $(PDI_FILE)

bootimage:
	@if [ ! -f "$(HW_PDI_MODE)" ] || [ "$$(cat "$(HW_PDI_MODE)")" != "FALSE" ]; then \
		echo "ERROR: Standalone boot requires a PDI produced by a clean PRE_SYNTH=FALSE hardware build."; \
		exit 1; \
	fi
	$(MAKE) $(BOOT_IMAGE)

$(BOOT_IMAGE): $(PDI_FILE) $(SW_FILES)
	$(info "BOOT image for platforms")
	$(BOOTGEN) -arch versal -image $(CWD)/bootgen.bif -o $(BOOT_IMAGE) -w;

clean:
	${RM} -r $(SW_DIR)
	${RM} -r $(PLATFORM_DIR)
	$(MAKE) -C dtb_gen clean ;
