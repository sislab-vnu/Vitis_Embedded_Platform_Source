#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************

include platform.mk

############################## Help Section ##############################
.PHONY: help

help::
	@echo 'Makefile Usage:'
	@echo ''
	@echo '  All the make commands install platform to "platform_repo/$(PLATFORM_NAME)/export/$(PLATFORM_NAME)"'
	@echo ''
	@echo '  make all'
	@echo '      Command used to generate platform with pre-built software components.'
	@echo ''
	@echo '  make all PREBUILT_LINUX_PATH=<path/to/common_sw/dir'
	@echo '			 Command used to generate platform with pre-built software components. By default, makefile looks for pre-built images in current directory or /opt/xilinx/platform/. Path to pre-built common images present in another dir can be passed to makefile manually using this command'
	@echo ''
	@echo '  *************************************************************************************************************'
	@echo '  *                                                                                                           *'
	@echo '  *  Please download Prebuilt Image using the following URL :                                                 *'
	@echo '  *                                                                                                           *'
	@echo '  *  https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-platforms.html *'
	@echo '  *                                                                                                           *'
	@echo '  *************************************************************************************************************'
	@echo ''
	@echo '  make all PRE_SYNTH=FALSE'
	@echo '      Command used to generate platform with post-impl xsa and pre-built software components.'
	@echo '      By default, PRE_SYNTH=TRUE.'
	@echo ''
	@echo '  make linux XSA=/home/user/$(PLATFORM_NAME)/vivado/build/$(PLATFORM_NAME).xsa'
	@echo '  make platform XSA=/home/user/$(PLATFORM_NAME)/vivado/build/$(PLATFORM_NAME).xsa'
	@echo '      Run these commands when XSA is already built in some other folder and no modifications are needed to it.'
	@echo '      XSA should point to $(PLATFORM_NAME).xsa file.'
	@echo ''
	@echo '  make clean '
	@echo '      Command to remove all the generated files.'
	@echo ''

.PHONY: all xsa linux platform clean

xsa: $(XSA)

HW_TCL_SOURCES = $(TOP_DIR)/hw/xsa_scripts/xsa.tcl $(TOP_DIR)/hw/xsa_scripts/project.tcl $(TOP_DIR)/hw/xsa_scripts/bd.tcl $(TOP_DIR)/hw/xsa_scripts/huins_vp1902_ddr.xdc $(TOP_DIR)/hw/xsa_scripts/huins_vp1902_io.xdc

ifeq ($(origin XSA),file)
PDI_MODE_FILE = $(XSA_DIR)/hw.pdi.mode
RECORDED_PRE_SYNTH := $(strip $(shell test -f $(PDI_MODE_FILE) && cat $(PDI_MODE_FILE)))

ifneq ($(RECORDED_PRE_SYNTH),$(PRE_SYNTH))
.PHONY: force-build-mode
$(XSA): force-build-mode
endif

$(XSA): $(HW_TCL_SOURCES)
$(XSA):
	$(MAKE) -C hw all
else
$(XSA):
	@echo "ERROR: External XSA does not exist: $(XSA)"
	@false
endif

linux: $(XSA)
	$(MAKE) -C sw all XSA="$(XSA)" PREBUILT_LINUX_PATH="$(PREBUILT_LINUX_PATH)"

all platform: $(XSA) linux

	@echo "INFO: Creating Platform $(PLATFORM_NAME)"

	vitis -s $(PLATFORM_SW_SRC)/generate_platform.py --platform_name $(PLATFORM_NAME) --xsa_path $(XSA) --boot_dir_path $(BOOT_DIR) --bif $(PLATFORM_BIF) --platform_out $(PLATFORM_DIR) --img_dir_path $(IMAGE_DIR) --dtb $(DTB_FILE)

	@if [ -d $(SW_DIR)/platform/filesystem ]; then cp -rf ${SW_DIR}/platform/filesystem $(PLATFORM_DIR)/${PLATFORM_NAME}/export/${PLATFORM_NAME}/sw/${PLATFORM_NAME}/xrt/; fi
	install -m 0644 $(TOP_DIR)/NETWORK_BRINGUP_GUIDE.md $(PLATFORM_EXPORT_DIR)/NETWORK_BRINGUP_GUIDE.md
	install -m 0644 $(TOP_DIR)/TCF_TUNNEL_GUIDE.md $(PLATFORM_EXPORT_DIR)/TCF_TUNNEL_GUIDE.md
	install -D -m 0644 $(TOP_DIR)/sw/prebuilt_linux/rootfs_overlay/etc/systemd/network/10-end0.network $(PLATFORM_EXPORT_DIR)/network/10-end0.network
	install -D -m 0755 $(TOP_DIR)/scripts/setup_huins_network.sh $(PLATFORM_EXPORT_DIR)/scripts/setup_huins_network.sh
	install -D -m 0644 $(TOP_DIR)/scripts/tcf_run_xclbin.tcl $(PLATFORM_EXPORT_DIR)/scripts/tcf_run_xclbin.tcl
	@echo "INFO: Checking created platforms:" && find . -name "*.xpfm"
	echo "Platform created:" && \
	find . -name "*.xpfm"


clean:
	$(MAKE) -C hw clean
	$(MAKE) -C sw clean
	${RM} -r $(PLATFORM_DIR)
