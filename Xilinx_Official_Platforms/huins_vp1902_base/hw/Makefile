#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************

include ../platform.mk

XSA_TCL = xsa_scripts/xsa.tcl
TCL_SOURCES = $(XSA_TCL) xsa_scripts/project.tcl xsa_scripts/bd.tcl xsa_scripts/huins_vp1902_ddr.xdc xsa_scripts/huins_vp1902_io.xdc
PDI_MODE_FILE = $(XSA_DIR)/hw.pdi.mode
RECORDED_PRE_SYNTH := $(strip $(shell test -f $(PDI_MODE_FILE) && cat $(PDI_MODE_FILE)))

ifneq ($(origin XSA),command line)
ifneq ($(RECORDED_PRE_SYNTH),$(PRE_SYNTH))
.PHONY: force-build-mode
$(XSA): force-build-mode
endif
endif

.PHONY: all xsa

all xsa : $(XSA)

$(XSA): $(TCL_SOURCES)
	$(RM) -f $(PDI_MODE_FILE)
	$(VIVADO) -mode batch -notrace -source $(XSA_TCL) -tclargs $(PLATFORM_NAME) $(VER) $(PRE_SYNTH)
ifeq ($(PRE_SYNTH),TRUE)
	unzip -p $(XSA) hw_presynth.pdi > $(XSA_DIR)/hw.pdi.tmp
	mv $(XSA_DIR)/hw.pdi.tmp $(XSA_DIR)/hw.pdi
endif
	@test -s $(XSA_DIR)/hw.pdi || { echo 'ERROR: Vivado did not produce a nonempty hw.pdi'; exit 1; }
	printf '%s\n' '$(PRE_SYNTH)' > $(PDI_MODE_FILE).tmp
	mv $(PDI_MODE_FILE).tmp $(PDI_MODE_FILE)

clean:
	$(RM) -r vivado* build .Xil *dynamic* *.log *.xpe 
