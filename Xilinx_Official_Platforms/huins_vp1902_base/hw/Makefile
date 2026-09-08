#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************

include ../platform.mk

XSA_TCL = xsa_scripts/xsa.tcl
TCL_SOURCES = $(XSA_TCL) xsa_scripts/project.tcl xsa_scripts/bd.tcl xsa_scripts/huins_vp1902_ddr.xdc xsa_scripts/huins_vp1902_io.xdc

.PHONY: all xsa

all xsa : $(XSA)

$(XSA): $(TCL_SOURCES)
	$(VIVADO) -mode batch -notrace -source $(XSA_TCL) -tclargs $(PLATFORM_NAME) $(VER) $(PRE_SYNTH)

clean:
	$(RM) -r vivado* build .Xil *dynamic* *.log *.xpe 
