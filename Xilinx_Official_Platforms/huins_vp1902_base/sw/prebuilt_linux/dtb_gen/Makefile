#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************


SHELL := /bin/bash
XSA ?= ../../../hw/build/hw.xsa
SDT_OUT ?= sdt_out
USER_DTSI ?= ../user_dts/system-user.dtsi 
DTB_OUT ?= system.dtb

all: gen_dtb

gen_sdt:
	$(RM) -rf $(SDT_OUT)
	$(info "DTB generation started using sdtgen+lopper")
	sdtgen -eval "sdtgen set_dt_param -dir $(SDT_OUT) -xsa $(XSA) -zocl enable -include_dts $(USER_DTSI); sdtgen generate_sdt"
 
gen_dtb: gen_sdt
	$(RM) -rf $(DTB_OUT)
	#source lopper_settings.sh; \
	#export LOPPER_DTC_FLAGS="-b 0 -@"; \
	#lopper -f --enhanced -O . -i ./lopper/lopper/lops/lop-a72-imux.dts $(SDT_OUT)/system-top.dts system.dtb -- gen_domain_dts psv_cortexa72_0 linux_dt
	#use lopper from TA
	
	lopper -f --enhanced -O . -i lop-a72-imux.dts $(SDT_OUT)/system-top.dts $(DTB_OUT) -- gen_domain_dts psv_cortexa72_0 linux_dt
	
clean:
	$(RM) -r *.dtb
	$(RM) -r  *.pp
	$(RM) -r sdt_out sdt_out_uboot sdt_out_linux
	$(RM) -r lopper
