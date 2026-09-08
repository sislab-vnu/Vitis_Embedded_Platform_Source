#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************
.PHONY: all linux clean

include ../platform.mk

all linux:
	$(MAKE) -C prebuilt_linux all XSA="$(XSA)" PREBUILT_LINUX_PATH="$(PREBUILT_LINUX_PATH)"

clean:
	$(MAKE) -C prebuilt_linux clean;
