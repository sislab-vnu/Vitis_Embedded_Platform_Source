#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************
################################################################
# This is a generated script based on design: huins_vp1902_base

#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################


# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./my_project/my_project.xpr> in the current working folder.
#
# NOTE: huins_vp1902_base targets a custom Huins board built around the
# Versal Premium xcvp1902. There is no Vivado board part for it, so the
# project pins the device part directly.
# CONFIRM the exact speed/temperature bin with Huins: 2MP-e-S vs 2LP-e-S
# (OPN "XCVP1902-2MSEVSVA6865" maps to one of these).
set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
    set projName "my_project"
    create_project $projName ./$projName -part xcvp1902-vsva6865-2MP-e-S
  }


#get Platform Name
set PLATFORM_NAME [lindex $argv 0]
set VER [lindex $argv 1]

# CHANGE DESIGN NAME HERE
variable design_name
set design_name vitis_design
create_bd_design $design_name
set_property PREFERRED_SIM_MODEL "tlm" [current_project]
