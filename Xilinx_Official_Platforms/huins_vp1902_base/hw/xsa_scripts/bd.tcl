
################################################################
# This is a generated script based on design: vp1902s_top
#
# Though there are limitations about the generated script,
#******************************************************************************
# huins_vp1902_base BD: built from the Huins reference write_bd_tcl
# (vp1902s_top.tcl) with reference-design extras stripped (HDMI/CSI/Aurora/
# Ethernet/ILA/dbg-hub/PL-DDR) and vck190-CED-style platform intent added
# (kernel clocks, GP smartconnects, axi_intc IRQs, PFM properties).
# Board facts + verified tool findings are in the platform README.md.
#******************************************************************************
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source vp1902s_top_script.tcl



# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvp1902-vsva6865-2MP-e-S
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name vitis_design

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_noc:1.1\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axi_ethernet:8.0\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:clk_wizard:1.0\
xilinx.com:ip:axis_ila:1.3\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:ps_wizard:1.0\
xilinx.com:ip:ddr4_pl:1.0\
xilinx.com:inline_hdl:ilconcat:1.0\
xilinx.com:inline_hdl:ilconstant:1.0\
xilinx.com:ip:axi_iic:2.1\
xilinx.com:ip:axi_timer:2.0\
xilinx.com:ip:axi_dbg_hub:2.0\
xilinx.com:ip:axis_subset_converter:1.1\
xilinx.com:ip:v_demosaic:1.1\
xilinx.com:ip:v_frmbuf_wr:3.0\
xilinx.com:ip:v_gamma_lut:1.1\
xilinx.com:ip:v_proc_ss:2.3\
xilinx.com:inline_hdl:ilslice:1.0\
xilinx.com:ip:mipi_csi2_rx_subsystem:6.0\
xilinx.com:ip:axis_register_slice:1.1\
xilinx.com:ip:v_hdmi_txss1:1.2\
xilinx.com:ip:v_frmbuf_rd:3.0\
xilinx.com:ip:bufg_gt:1.0\
xilinx.com:ip:aurora_64b66b:13.0\
xilinx.com:ip:util_ds_buf:2.2\
xilinx.com:ip:gt_quad_base:1.1\
xilinx.com:ip:axis_vio:1.0\
xilinx.com:ip:hdmi_gt_controller:2.0\
xilinx.com:ip:gtwiz_versal:1.0\
xilinx.com:inline_hdl:ilreduced_logic:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: hdmiphy_ss

# Hierarchical cell: gt_refclk_buf_ss_1

# Hierarchical cell: hsdp_soft_aurora

# Hierarchical cell: hdmi_hier_0

# Hierarchical cell: csi_mipi_csi_rx_ss

# Hierarchical cell: csi_cap_pipe


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set C0_DDR4_SYS [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 C0_DDR4_SYS ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $C0_DDR4_SYS

  set GEM1_MDIO [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 GEM1_MDIO ]

  set I2C1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 I2C1 ]

  set I2C0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 I2C0 ]

  set UART0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART0 ]

  set UART1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART1 ]






  set C1_DDR4_SYS [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 C1_DDR4_SYS ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $C1_DDR4_SYS


  set C0_DDR4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 C0_DDR4 ]

  set C1_DDR4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 C1_DDR4 ]











  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_0 ]
  set_property -dict [list \
    CONFIG.CONTROLLERTYPE {DDR4_SDRAM} \
    CONFIG.MC0_CONFIG_NUM {config17} \
    CONFIG.MC0_FLIPPED_PINOUT {false} \
    CONFIG.MC1_CONFIG_NUM {config17} \
    CONFIG.MC2_CONFIG_NUM {config17} \
    CONFIG.MC3_CONFIG_NUM {config17} \
    CONFIG.MC_CAL_MASK_POLL {ENABLE} \
    CONFIG.MC_CASLATENCY {17} \
    CONFIG.MC_CASWRITELATENCY {12} \
    CONFIG.MC_CA_MIRROR {true} \
    CONFIG.MC_CHAN_REGION0 {DDR_LOW0} \
    CONFIG.MC_CHAN_REGION1 {DDR_LOW2} \
    CONFIG.MC_CKE_WIDTH {2} \
    CONFIG.MC_CK_WIDTH {2} \
    CONFIG.MC_COMPONENT_WIDTH {x8} \
    CONFIG.MC_CONFIG_NUM {config17} \
    CONFIG.MC_CS_WIDTH {2} \
    CONFIG.MC_DATAWIDTH {64} \
    CONFIG.MC_DDR4_2T {Disable} \
    CONFIG.MC_DDR4_MIGRATION {false} \
    CONFIG.MC_DM_WIDTH {8} \
    CONFIG.MC_DQS_WIDTH {8} \
    CONFIG.MC_DQ_WIDTH {64} \
    CONFIG.MC_ECC_SCRUB_SIZE {32768} \
    CONFIG.MC_EN_INTR_RESP {FALSE} \
    CONFIG.MC_F1_TRCD {13750} \
    CONFIG.MC_F1_TRCDMIN {13750} \
    CONFIG.MC_FREQ_SEL {MEMORY_CLK_FROM_SYS_CLK} \
    CONFIG.MC_INTERLEAVE_SIZE {256} \
    CONFIG.MC_IP_TIMEPERIOD0_FOR_OP {5000} \
    CONFIG.MC_MEMORY_DEVICETYPE {SODIMMs} \
    CONFIG.MC_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
    CONFIG.MC_ODT_WIDTH {2} \
    CONFIG.MC_OP_TIMEPERIOD0 {833} \
    CONFIG.MC_OP_TIMEPERIOD1 {690} \
    CONFIG.MC_PARITY {true} \
    CONFIG.MC_PARITYLATENCY {5} \
    CONFIG.MC_RANK {2} \
    CONFIG.MC_REF_AND_PER_CAL_INTF {FALSE} \
    CONFIG.MC_ROWADDRESSWIDTH {17} \
    CONFIG.MC_TCCD_L {7} \
    CONFIG.MC_TCCD_L_MIN {7} \
    CONFIG.MC_TCKE {7} \
    CONFIG.MC_TCKEMIN {7} \
    CONFIG.MC_TRC {45750} \
    CONFIG.MC_TRCD {13750} \
    CONFIG.MC_TRCDMIN {13750} \
    CONFIG.MC_TRCMIN {45750} \
    CONFIG.MC_TRFC {550000} \
    CONFIG.MC_TRFCMIN {550000} \
    CONFIG.MC_TRP {13750} \
    CONFIG.MC_TRPMIN {13750} \
    CONFIG.MC_TRRD_L {6} \
    CONFIG.MC_TRRD_L_MIN {6} \
    CONFIG.MC_TXP {8} \
    CONFIG.MC_TXPMIN {8} \
    CONFIG.MC_TXPR {673} \
    CONFIG.MC_USER_DEFINED_ADDRESS_MAP {1CS-17RA-2BA-2BG-10CA} \
    CONFIG.MC_WRITE_DM_DBI {DM_NO_DBI} \
    CONFIG.MC_XPLL_CLKOUT1_PERIOD {1666} \
    CONFIG.NUM_CLKS {12} \
    CONFIG.NUM_MC {2} \
    CONFIG.NUM_MCP {2} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {10} \
  ] $axi_noc_0


  set_property -dict [ list \
   CONFIG.APERTURES {{0x800_0000_0000 128G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {false}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins $axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins $axi_noc_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}} \
   CONFIG.DEST_IDS {M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins $axi_noc_0/S02_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}} \
   CONFIG.DEST_IDS {M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins $axi_noc_0/S03_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}} \
   CONFIG.DEST_IDS {M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins $axi_noc_0/S04_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins $axi_noc_0/S05_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc_0/S06_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc_0/S07_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 {read_bw {1720} write_bw {1720} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {1720} write_bw {1720} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc_0/S08_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 {read_bw {1720} write_bw {1720} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {1720} write_bw {1720} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc_0/S09_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S05_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk5]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S06_AXI:S07_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk6]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk7]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S08_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk8]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {} \
 ] [get_bd_pins $axi_noc_0/aclk9]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {} \
 ] [get_bd_pins $axi_noc_0/aclk10]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S09_AXI} \
 ] [get_bd_pins $axi_noc_0/aclk11]

  # Create instance: util_vector_logic_0, and set properties


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: axi_ethernet_0, and set properties


    
  # Create instance: axi_ethernet_0_dma, and set properties


  # Create instance: smartconnect_0, and set properties


  # Create instance: axi_ethernet_1, and set properties


    
  # Create instance: axi_ethernet_1_dma, and set properties


  # Create instance: smartconnect_1, and set properties


  # Create instance: axi_gpio_0, and set properties


  # Create instance: clk_wizard_0, and set properties
  set clk_wizard_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard:1.0 clk_wizard_0 ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {125,100.000,100.000,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,false,false,false,false,false,false} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {true} \
  ] $clk_wizard_0


  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create instance: rst_ddr4_pl_c2, and set properties

  # Create instance: proc_sys_reset_2, and set properties
  set proc_sys_reset_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_2 ]

  # Create instance: axis_ila_1, and set properties


  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_0


  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property -dict [list \
    CONFIG.ADVANCED_PROPERTIES { __view__ { clocking { M04_Exit { ASSOCIATED_CLK aclk } } }} \
    CONFIG.NUM_CLKS {3} \
    CONFIG.NUM_MI {7} \
    CONFIG.NUM_SI {1} \
  ] $axi_smc


  # Create instance: axis_ila_0, and set properties


  # Create instance: ps_wizard_0, and set properties
  set ps_wizard_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ps_wizard:1.0 ps_wizard_0 ]
  set_property -dict [list \
    CONFIG.PS_PMC_CONFIG(BOOT_SECONDARY_PCIE_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(CPM6_PERIPHERAL_EN) {0} \
    CONFIG.PS_PMC_CONFIG(CPM_PCIE0_TANDEM) {None} \
    CONFIG.PS_PMC_CONFIG(DESIGN_MODE) {1} \
    CONFIG.PS_PMC_CONFIG(DIS_AUTO_POL_CHECK) {0} \
    CONFIG.PS_PMC_CONFIG(GT_REFCLK_MHZ) {156.25} \
    CONFIG.PS_PMC_CONFIG(JTAG_USERCODE) {0x0} \
    CONFIG.PS_PMC_CONFIG(OT_EAM_RESP) {SRST} \
    CONFIG.PS_PMC_CONFIG(PCIE_APERTURES_DUAL_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PCIE_APERTURES_SINGLE_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PL_SEM_GPIO_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_ALT_REF_CLK_FREQMHZ) {33.333} \
    CONFIG.PS_PMC_CONFIG(PMC_BANK_0_IO_STANDARD) {LVCMOS1.8} \
    CONFIG.PS_PMC_CONFIG(PMC_BANK_1_IO_STANDARD) {LVCMOS1.8} \
    CONFIG.PS_PMC_CONFIG(PMC_CLKMON0_CONFIG) {ENABLE 0 THRESHOLD_U 0 THRESHOLD_L 0 BASE 10000 CLKA_SEL REF_CLK CLKA_FREQ 1000 BASE_CLK_SRC REF_CLK INTR 0} \
    CONFIG.PS_PMC_CONFIG(PMC_CLKMON1_CONFIG) {ENABLE 0 THRESHOLD_U 0 THRESHOLD_L 0 BASE 10000 CLKA_SEL REF_CLK CLKA_FREQ 1000 BASE_CLK_SRC REF_CLK INTR 0} \
    CONFIG.PS_PMC_CONFIG(PMC_CLKMON2_CONFIG) {ENABLE 0 THRESHOLD_U 0 THRESHOLD_L 0 BASE 10000 CLKA_SEL REF_CLK CLKA_FREQ 1000 BASE_CLK_SRC REF_CLK INTR 0} \
    CONFIG.PS_PMC_CONFIG(PMC_CLKMON3_CONFIG) {ENABLE 0 THRESHOLD_U 0 THRESHOLD_L 0 BASE 10000 CLKA_SEL REF_CLK CLKA_FREQ 1000 BASE_CLK_SRC REF_CLK INTR 0} \
    CONFIG.PS_PMC_CONFIG(PMC_CLKMON4_CONFIG) {ENABLE 0 THRESHOLD_U 0 THRESHOLD_L 0 BASE 10000 CLKA_SEL REF_CLK CLKA_FREQ 1000 BASE_CLK_SRC REF_CLK INTR 0} \
    CONFIG.PS_PMC_CONFIG(PMC_CLKMON5_CONFIG) {ENABLE 0 THRESHOLD_U 0 THRESHOLD_L 0 BASE 10000 CLKA_SEL REF_CLK CLKA_FREQ 1000 BASE_CLK_SRC REF_CLK INTR 0} \
    CONFIG.PS_PMC_CONFIG(PMC_CLKMON6_CONFIG) {ENABLE 0 THRESHOLD_U 0 THRESHOLD_L 0 BASE 10000 CLKA_SEL REF_CLK CLKA_FREQ 1000 BASE_CLK_SRC REF_CLK INTR 0} \
    CONFIG.PS_PMC_CONFIG(PMC_CLKMON7_CONFIG) {ENABLE 0 THRESHOLD_U 0 THRESHOLD_L 0 BASE 10000 CLKA_SEL REF_CLK CLKA_FREQ 1000 BASE_CLK_SRC REF_CLK INTR 0} \
    CONFIG.PS_PMC_CONFIG(PMC_CORE_SUBSYSTEM_LOAD) {10} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_CFU_REF_CTRL_FREQMHZ) {400} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_DFT_OSC_REF_CTRL_DIVISOR0) {3} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_DFT_OSC_REF_CTRL_FREQMHZ) {400} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_DFT_OSC_REF_CTRL_SRCSEL) {PPLL} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_EFUSE_REF_CTRL_SRCSEL) {IRO_CLK/4} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_HSM0_REF_CTRL_FREQMHZ) {33.333} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_HSM1_REF_CTRL_FREQMHZ) {133.333} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_LSBUS_REF_CTRL_FREQMHZ) {150} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_NOC_REF_CTRL_FREQMHZ) {1000} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_NPLL_CTRL_SRCSEL) {REF_CLK} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_PL0_REF_CTRL_FREQMHZ) {100} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_PL1_REF_CTRL_FREQMHZ) {300} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_PL2_REF_CTRL_FREQMHZ) {200} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_PL3_REF_CTRL_FREQMHZ) {125} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_PPLL_CTRL_SRCSEL) {REF_CLK} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_QSPI_REF_CTRL_FREQMHZ) {150} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_SWITCH_TIMEOUT_CTRL_FREQMHZ) {1} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_TEST_PATTERN_REF_CTRL_DIVISOR0) {6} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_TEST_PATTERN_REF_CTRL_FREQMHZ) {200} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_TEST_PATTERN_REF_CTRL_SRCSEL) {PPLL} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_USB_SUSPEND_CTRL_FREQMHZ) {0.2} \
    CONFIG.PS_PMC_CONFIG(PMC_ERROR_TO_PL) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_EXTERNAL_TAMPER) {ENABLE 0 IO PMC_MIO_12} \
    CONFIG.PS_PMC_CONFIG(PMC_GLITCH_CONFIG) {TYPE EFUSE VCC_PMC_VALUE 0.80 DEPTH_SENSITIVITY 1 MIN_PULSE_WIDTH 0.5} \
    CONFIG.PS_PMC_CONFIG(PMC_GPIO0_MIO_PERIPHERAL) {ENABLE 0 IO PMC_MIO_0:25} \
    CONFIG.PS_PMC_CONFIG(PMC_GPIO1_MIO_PERIPHERAL) {ENABLE 0 IO PMC_MIO_26:51} \
    CONFIG.PS_PMC_CONFIG(PMC_GPIO_EMIO_PERIPHERAL_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_GPIO_EMIO_WIDTH_HDL) {64} \
    CONFIG.PS_PMC_CONFIG(PMC_GPI_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_GPI_WIDTH) {32} \
    CONFIG.PS_PMC_CONFIG(PMC_GPO_WIDTH) {32} \
    CONFIG.PS_PMC_CONFIG(PMC_HSM0_CLK_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PMC_HSM0_CLK_OUT_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_HSM1_CLK_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PMC_HSM1_CLK_OUT_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_I2CPMC_PERIPHERAL) {ENABLE 0 IO PMC_MIO_2:3 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO0) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO1) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO10) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO11) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO12) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO13) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO14) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO15) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO16) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO17) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO18) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO19) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO2) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO20) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO21) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO22) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO23) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO24) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO25) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO26) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO27) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO28) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO29) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO3) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO30) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO31) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO32) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO33) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO34) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO35) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO36) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO37) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO38) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO39) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO4) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO40) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO41) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO42) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO43) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO44) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO45) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO46) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO47) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO48) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO49) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO5) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO50) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO51) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO6) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO7) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO8) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO9) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO_TREE_PERIPHERALS) {QSPI#QSPI#QSPI#QSPI#QSPI#QSPI#Loopback_Clk#QSPI#QSPI#QSPI#QSPI#QSPI#QSPI#USB_2.0#USB_2.0#USB_2.0#USB_2.0#USB_2.0#USB_2.0#USB_2.0#USB_2.0#USB_2.0#USB_2.0#USB_2.0#USB_2.0#USB_2.0#SD1(3.0AD)##SD1(3.0AD)#SD1(3.0AD)#SD1(3.0AD)#SD1(3.0AD)#SD1(3.0AD)#SD1(3.0AD)#SD1(3.0AD)####Gem1#Gem1#Gem1#Gem1#Gem1#Gem1#Gem1#Gem1#Gem1#Gem1#Gem1#Gem1#SD1(3.0AD)#SD1(3.0AD)##########################}\
\
    CONFIG.PS_PMC_CONFIG(PMC_MIO_TREE_SIGNALS) {qspi0_clk#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_io[0]#qspi0_cs_b#qspi_lpbk#qspi1_cs_b#qspi1_io[0]#qspi1_io[1]#qspi1_io[2]#qspi1_io[3]#qspi1_clk#usb2phy_reset#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_tx_data[2]#ulpi_tx_data[3]#ulpi_clk#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#ulpi_dir#ulpi_stp#ulpi_nxt#clk##detect#cmd#data[0]#data[1]#data[2]#data[3]#sel####rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#wp#buspwr##########################}\
\
    CONFIG.PS_PMC_CONFIG(PMC_NOC_PMC_ADDR_WIDTH) {64} \
    CONFIG.PS_PMC_CONFIG(PMC_OSPI_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO PMC_MIO_0:13 MODE Single} \
    CONFIG.PS_PMC_CONFIG(PMC_OT_CHECK) {ENABLE 1 DELAY 0} \
    CONFIG.PS_PMC_CONFIG(PMC_PL_ALT_REF_CLK_FREQMHZ) {33.333} \
    CONFIG.PS_PMC_CONFIG(PMC_PMC_NOC_ADDR_WIDTH) {64} \
    CONFIG.PS_PMC_CONFIG(PMC_QSPI_BAUD_RATE_DIV) {8} \
    CONFIG.PS_PMC_CONFIG(PMC_QSPI_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_QSPI_FBCLK) {ENABLE 1 IO PMC_MIO_6} \
    CONFIG.PS_PMC_CONFIG(PMC_QSPI_PERIPHERAL) {PRIMARY_ENABLE 1 SECONDARY_ENABLE 0 MODE Dual_Parallel} \
    CONFIG.PS_PMC_CONFIG(PMC_QSPI_PERIPHERAL_DATA_MODE) {x4} \
    CONFIG.PS_PMC_CONFIG(PMC_QSPI_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_REF_CLK_FREQMHZ) {33.333} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_20) {CD_ENABLE 0 POW_ENABLE 0 WP_ENABLE 0 RESET_ENABLE 0 CD_IO PMC_MIO_24 POW_IO PMC_MIO_17 WP_IO PMC_MIO_25 RESET_IO PMC_MIO_17 CLK_50_SDR_ITAP_DLY 0x00 CLK_50_SDR_OTAP_DLY\
0x00 CLK_50_DDR_ITAP_DLY 0x00 CLK_50_DDR_OTAP_DLY 0x00 CLK_100_SDR_OTAP_DLY 0x00 CLK_200_SDR_OTAP_DLY 0x00} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_20_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO PMC_MIO_13:25 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_30) {CD_ENABLE 0 POW_ENABLE 0 WP_ENABLE 0 RESET_ENABLE 0 CD_IO PMC_MIO_24 POW_IO PMC_MIO_17 WP_IO PMC_MIO_25 RESET_IO PMC_MIO_17 CLK_50_SDR_ITAP_DLY 0x00 CLK_50_SDR_OTAP_DLY\
0x00 CLK_50_DDR_ITAP_DLY 0x00 CLK_50_DDR_OTAP_DLY 0x00 CLK_100_SDR_OTAP_DLY 0x00 CLK_200_SDR_OTAP_DLY 0x00} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_30AD) {CD_ENABLE 0 POW_ENABLE 0 WP_ENABLE 0 RESET_ENABLE 0 CD_IO PMC_MIO_24 POW_IO PMC_MIO_17 WP_IO PMC_MIO_25 RESET_IO PMC_MIO_17 CLK_50_SDR_ITAP_DLY 0x00 CLK_50_SDR_OTAP_DLY\
0x00 CLK_50_DDR_ITAP_DLY 0x00 CLK_50_DDR_OTAP_DLY 0x00 CLK_100_SDR_OTAP_DLY 0x00 CLK_200_SDR_OTAP_DLY 0x00} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_30AD_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO PMC_MIO_13:25 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_30_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO PMC_MIO_13:25 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_EMMC) {CD_ENABLE 0 POW_ENABLE 0 WP_ENABLE 0 RESET_ENABLE 0 CD_IO PMC_MIO_24 POW_IO PMC_MIO_17 WP_IO PMC_MIO_25 RESET_IO PMC_MIO_17 CLK_50_SDR_ITAP_DLY 0x00 CLK_50_SDR_OTAP_DLY\
0x00 CLK_50_DDR_ITAP_DLY 0x00 CLK_50_DDR_OTAP_DLY 0x00 CLK_100_SDR_OTAP_DLY 0x00 CLK_200_SDR_OTAP_DLY 0x00} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_EMMC_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO PMC_MIO_13:25 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_20) {CD_ENABLE 0 POW_ENABLE 0 WP_ENABLE 0 RESET_ENABLE 0 CD_IO PMC_MIO_2 POW_IO PMC_MIO_12 WP_IO PMC_MIO_1 RESET_IO PMC_MIO_12 CLK_50_SDR_ITAP_DLY 0x00 CLK_50_SDR_OTAP_DLY\
0x00 CLK_50_DDR_ITAP_DLY 0x00 CLK_50_DDR_OTAP_DLY 0x00 CLK_100_SDR_OTAP_DLY 0x00 CLK_200_SDR_OTAP_DLY 0x00} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_20_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO PMC_MIO_0:11 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_30) {CD_ENABLE 0 POW_ENABLE 0 WP_ENABLE 0 RESET_ENABLE 0 CD_IO PMC_MIO_2 POW_IO PMC_MIO_12 WP_IO PMC_MIO_1 RESET_IO PMC_MIO_12 CLK_50_SDR_ITAP_DLY 0x00 CLK_50_SDR_OTAP_DLY\
0x00 CLK_50_DDR_ITAP_DLY 0x00 CLK_50_DDR_OTAP_DLY 0x00 CLK_100_SDR_OTAP_DLY 0x00 CLK_200_SDR_OTAP_DLY 0x00} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_30AD) {CD_ENABLE 1 POW_ENABLE 1 WP_ENABLE 1 RESET_ENABLE 0 CD_IO PMC_MIO_28 POW_IO PMC_MIO_51 WP_IO PMC_MIO_50 RESET_IO PMC_MIO_12 CLK_50_SDR_ITAP_DLY 0x25 CLK_50_SDR_OTAP_DLY\
0x4 CLK_50_DDR_ITAP_DLY 0x2A CLK_50_DDR_OTAP_DLY 0x3 CLK_100_SDR_OTAP_DLY 0x3 CLK_200_SDR_OTAP_DLY 0x2} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_30AD_PERIPHERAL) {PRIMARY_ENABLE 1 SECONDARY_ENABLE 0 IO PMC_MIO_26:36 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_30_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO PMC_MIO_0:11 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_DATA_TRANSFER_MODE) {4Bit_autodir} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_EMMC) {CD_ENABLE 0 POW_ENABLE 0 WP_ENABLE 0 RESET_ENABLE 0 CD_IO PMC_MIO_2 POW_IO PMC_MIO_12 WP_IO PMC_MIO_1 RESET_IO PMC_MIO_12 CLK_50_SDR_ITAP_DLY 0x00 CLK_50_SDR_OTAP_DLY\
0x00 CLK_50_DDR_ITAP_DLY 0x00 CLK_50_DDR_OTAP_DLY 0x00 CLK_100_SDR_OTAP_DLY 0x00 CLK_200_SDR_OTAP_DLY 0x00} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_EMMC_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO PMC_MIO_0:11 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_SLOT_TYPE) {SD_3.0_AUTODIR} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_SPEED_MODE) {high_speed} \
    CONFIG.PS_PMC_CONFIG(PMC_SHOW_CCI_SMMU_SETTINGS) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_SMAP_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO 32_Bit} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_EXTMIO_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_GLITCHDETECT_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_JTAGDETECT_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP0) {ENABLE 0 SUPPLY_NUM 0 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP1) {ENABLE 0 SUPPLY_NUM 1 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP10) {ENABLE 0 SUPPLY_NUM 10 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP11) {ENABLE 0 SUPPLY_NUM 11 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP12) {ENABLE 0 SUPPLY_NUM 12 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP13) {ENABLE 0 SUPPLY_NUM 13 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP14) {ENABLE 0 SUPPLY_NUM 14 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP15) {ENABLE 0 SUPPLY_NUM 15 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP16) {ENABLE 0 SUPPLY_NUM 16 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP17) {ENABLE 0 SUPPLY_NUM 17 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP18) {ENABLE 0 SUPPLY_NUM 18 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP19) {ENABLE 0 SUPPLY_NUM 19 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP2) {ENABLE 0 SUPPLY_NUM 2 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP20) {ENABLE 0 SUPPLY_NUM 20 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP21) {ENABLE 0 SUPPLY_NUM 21 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP22) {ENABLE 0 SUPPLY_NUM 22 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP23) {ENABLE 0 SUPPLY_NUM 23 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP24) {ENABLE 0 SUPPLY_NUM 24 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP25) {ENABLE 0 SUPPLY_NUM 25 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP26) {ENABLE 0 SUPPLY_NUM 26 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP27) {ENABLE 0 SUPPLY_NUM 27 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP28) {ENABLE 0 SUPPLY_NUM 28 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP29) {ENABLE 0 SUPPLY_NUM 29 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP3) {ENABLE 0 SUPPLY_NUM 3 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP30) {ENABLE 0 SUPPLY_NUM 30 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP31) {ENABLE 0 SUPPLY_NUM 31 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP4) {ENABLE 0 SUPPLY_NUM 4 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP5) {ENABLE 0 SUPPLY_NUM 5 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP6) {ENABLE 0 SUPPLY_NUM 6 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP7) {ENABLE 0 SUPPLY_NUM 7 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP8) {ENABLE 0 SUPPLY_NUM 8 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP9) {ENABLE 0 SUPPLY_NUM 9 VOLTAGE none AVG_ENABLE 0 ADC_MODE none IO_N none IO_P none TH_LOW 0 TH_HIGH 0 TH_MIN 0 TH_MAX 0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_SUP_0_31_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_TAMPER_TEMPERATURE_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_USE_CFU_SEU) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_USE_NOC_AXI_PMC0) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_USE_PL_ERR0) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_USE_PL_ERR1) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_USE_PL_ERR2) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_USE_PL_ERR3) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_USE_PL_PMC_AUX_REF_CLK) {0} \
    CONFIG.PS_PMC_CONFIG(PMC_USE_PMC_AXI_NOC0) {1} \
    CONFIG.PS_PMC_CONFIG(PMC_WDT_PERIPHERAL) {ENABLE 0 IO PMC_MIO_0} \
    CONFIG.PS_PMC_CONFIG(PSPMC_MANUAL_CLK_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_A72_ACTIVE_BLOCKS) {2} \
    CONFIG.PS_PMC_CONFIG(PS_A72_LOAD) {90} \
    CONFIG.PS_PMC_CONFIG(PS_BANK_2_IO_STANDARD) {LVCMOS1.8} \
    CONFIG.PS_PMC_CONFIG(PS_BANK_3_IO_STANDARD) {LVCMOS1.8} \
    CONFIG.PS_PMC_CONFIG(PS_BOARD_INTERFACE) {Custom} \
    CONFIG.PS_PMC_CONFIG(PS_CAN0_CLK) {ENABLE 0 IO PMC_MIO_0} \
    CONFIG.PS_PMC_CONFIG(PS_CAN0_PERIPHERAL) {ENABLE 0 IO PMC_MIO_8:9 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_CAN1_CLK) {ENABLE 0 IO PMC_MIO_0} \
    CONFIG.PS_PMC_CONFIG(PS_CAN1_PERIPHERAL) {ENABLE 0 IO PMC_MIO_10:11 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_CRF_ACPU_CTRL_FREQMHZ) {1400} \
    CONFIG.PS_PMC_CONFIG(PS_CRF_APLL_CTRL_SRCSEL) {REF_CLK} \
    CONFIG.PS_PMC_CONFIG(PS_CRF_DBG_FPD_CTRL_FREQMHZ) {400} \
    CONFIG.PS_PMC_CONFIG(PS_CRF_FPD_LSBUS_CTRL_FREQMHZ) {150} \
    CONFIG.PS_PMC_CONFIG(PS_CRF_FPD_TOP_SWITCH_CTRL_FREQMHZ) {825} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_CPM_TOPSW_REF_CTRL_FREQMHZ) {825} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_CPU_R5_CTRL_FREQMHZ) {600} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_DBG_LPD_CTRL_FREQMHZ) {400} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_DBG_TSTMP_CTRL_FREQMHZ) {400} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_GEM1_REF_CTRL_FREQMHZ) {125} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_GEM_TSU_REF_CTRL_FREQMHZ) {250} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_I2C0_REF_CTRL_FREQMHZ) {100} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_I2C1_REF_CTRL_FREQMHZ) {100} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_IOU_SWITCH_CTRL_FREQMHZ) {250} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_LPD_LSBUS_CTRL_FREQMHZ) {150} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_LPD_TOP_SWITCH_CTRL_FREQMHZ) {600} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_PSM_REF_CTRL_FREQMHZ) {400} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_RPLL_CTRL_SRCSEL) {REF_CLK} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_TIMESTAMP_REF_CTRL_FREQMHZ) {100} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_UART0_REF_CTRL_FREQMHZ) {100} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_UART1_REF_CTRL_FREQMHZ) {100} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_USB0_BUS_REF_CTRL_FREQMHZ) {20} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_USB3_DUAL_REF_CTRL_ACT_FREQMHZ) {20} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_USB3_DUAL_REF_CTRL_DIVISOR0) {60} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_USB3_DUAL_REF_CTRL_FREQMHZ) {10} \
    CONFIG.PS_PMC_CONFIG(PS_CRL_USB3_DUAL_REF_CTRL_SRCSEL) {PPLL} \
    CONFIG.PS_PMC_CONFIG(PS_DDRC_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_DDR_RAM_HIGHADDR_OFFSET) {0x800000000} \
    CONFIG.PS_PMC_CONFIG(PS_DDR_RAM_LOWADDR_OFFSET) {0x80000000} \
    CONFIG.PS_PMC_CONFIG(PS_ENET0_MDIO) {ENABLE 0 IO PMC_MIO_50:51 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_ENET0_PERIPHERAL) {ENABLE 0 IO PMC_MIO_26:37 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_ENET1_MDIO) {ENABLE 1 IO EMIO IO_TYPE EMIO} \
    CONFIG.PS_PMC_CONFIG(PS_ENET1_PERIPHERAL) {ENABLE 1 IO PMC_MIO_38:49 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_EN_AXI_STATUS_PORTS) {0} \
    CONFIG.PS_PMC_CONFIG(PS_EN_PORTS_CONTROLLER_BASED) {0} \
    CONFIG.PS_PMC_CONFIG(PS_EXPAND_CORESIGHT) {0} \
    CONFIG.PS_PMC_CONFIG(PS_EXPAND_FPD_SLAVES) {0} \
    CONFIG.PS_PMC_CONFIG(PS_EXPAND_GIC) {0} \
    CONFIG.PS_PMC_CONFIG(PS_EXPAND_LPD_SLAVES) {0} \
    CONFIG.PS_PMC_CONFIG(PS_FPD_AXI_NOC_DATA_WIDTH) {128} \
    CONFIG.PS_PMC_CONFIG(PS_FPD_AXI_PL_DATA_WIDTH) {128} \
    CONFIG.PS_PMC_CONFIG(PS_FPD_CCI_NOC_DATA_WIDTH) {128} \
    CONFIG.PS_PMC_CONFIG(PS_FPD_INTERCONNECT_LOAD) {90} \
    CONFIG.PS_PMC_CONFIG(PS_FTM_CTI_IN0) {0} \
    CONFIG.PS_PMC_CONFIG(PS_FTM_CTI_IN1) {0} \
    CONFIG.PS_PMC_CONFIG(PS_FTM_CTI_IN2) {0} \
    CONFIG.PS_PMC_CONFIG(PS_FTM_CTI_IN3) {0} \
    CONFIG.PS_PMC_CONFIG(PS_FTM_CTI_OUT0) {0} \
    CONFIG.PS_PMC_CONFIG(PS_FTM_CTI_OUT1) {0} \
    CONFIG.PS_PMC_CONFIG(PS_FTM_CTI_OUT2) {0} \
    CONFIG.PS_PMC_CONFIG(PS_FTM_CTI_OUT3) {0} \
    CONFIG.PS_PMC_CONFIG(PS_GEM1_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_GEM1_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_GEM_TSU) {ENABLE 0 IO PMC_MIO_50 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_GEM_TSU_CLK_PORT_PAIR) {0} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI0_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI0_MASTER) {A72} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI1_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI1_MASTER) {A72} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI2_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI2_MASTER) {A72} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI3_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI3_MASTER) {A72} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI4_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI4_MASTER) {A72} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI5_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI5_MASTER) {A72} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI6_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI6_MASTER) {A72} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI_PMCNOBUF_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI_PMCNOBUF_MASTER) {PMC} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI_PMC_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI_PMC_MASTER) {PMC} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI_PSM_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI_PSM_MASTER) {PSM} \
    CONFIG.PS_PMC_CONFIG(PS_GPIO2_MIO_PERIPHERAL) {ENABLE 0 IO PS_MIO_0:25} \
    CONFIG.PS_PMC_CONFIG(PS_GPIO_EMIO_PERIPHERAL_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_HSDP0_REFCLK) {0} \
    CONFIG.PS_PMC_CONFIG(PS_HSDP1_REFCLK) {0} \
    CONFIG.PS_PMC_CONFIG(PS_HSDP_INGRESS_TRAFFIC) {PL} \
    CONFIG.PS_PMC_CONFIG(PS_HSDP_SAME_EGRESS_AS_INGRESS_TRAFFIC) {1} \
    CONFIG.PS_PMC_CONFIG(PS_I2C0_PERIPHERAL) {ENABLE 1 IO EMIO IO_TYPE EMIO} \
    CONFIG.PS_PMC_CONFIG(PS_I2C1_PERIPHERAL) {ENABLE 1 IO EMIO IO_TYPE EMIO} \
    CONFIG.PS_PMC_CONFIG(PS_I2CSYSMON_PERIPHERAL) {ENABLE 0 IO_TYPE MIO IO PMC_MIO_4:5} \
    CONFIG.PS_PMC_CONFIG(PS_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 1 CH4 1 CH5 1 CH6 1 CH7 1 CH8 1 CH9 1 CH10 1 CH11 1 CH12 1 CH13 1 CH14 1 CH15 1} \
    CONFIG.PS_PMC_CONFIG(PS_KAT_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA0_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA0_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA1_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA1_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA2_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA2_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA3_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA3_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA4_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA4_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA5_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA5_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA6_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA6_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA7_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPDMA7_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPD_AXI_NOC_DATA_WIDTH) {128} \
    CONFIG.PS_PMC_CONFIG(PS_LPD_DMA_CHANNEL_ENABLE) {CH0 0 CH1 0 CH2 0 CH3 0 CH4 0 CH5 0 CH6 0 CH7 0} \
    CONFIG.PS_PMC_CONFIG(PS_LPD_DMA_CH_TZ) {CH0 NonSecure CH1 NonSecure CH2 NonSecure CH3 NonSecure CH4 NonSecure CH5 NonSecure CH6 NonSecure CH7 NonSecure} \
    CONFIG.PS_PMC_CONFIG(PS_LPD_DMA_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_LPD_INTERCONNECT_LOAD) {90} \
    CONFIG.PS_PMC_CONFIG(PS_MIO0) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO1) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO10) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO11) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO12) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO13) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO14) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO15) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO16) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO17) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO18) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO19) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO2) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO20) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO21) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO22) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO23) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO24) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO25) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO3) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO4) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO5) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO6) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO7) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO8) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO9) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE Unassigned OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_NOC_AXI_FPD0_BRIDGES) {FPD_AXI_NOC0 0 FPD_AXI_PL 0 LPD_AXI_PL 0} \
    CONFIG.PS_PMC_CONFIG(PS_NOC_AXI_FPD1_BRIDGES) {FPD_AXI_NOC1 0 FPD_AXI_PL 0 LPD_AXI_PL 0} \
    CONFIG.PS_PMC_CONFIG(PS_NOC_AXI_FPD_DATA_WIDTH) {128} \
    CONFIG.PS_PMC_CONFIG(PS_NOC_AXI_PMC0_BRIDGES) {LPD_AXI_PL 0} \
    CONFIG.PS_PMC_CONFIG(PS_NOC_AXI_PMC_DATA_WIDTH) {128} \
    CONFIG.PS_PMC_CONFIG(PS_NOC_CCI_FPD0_BRIDGES) {FPD_CCI_NOC0 0 FPD_CCI_NOC1 0 FPD_CCI_NOC2 0 FPD_CCI_NOC3 0 FPD_AXI_PL 0 LPD_AXI_PL 0} \
    CONFIG.PS_PMC_CONFIG(PS_NOC_CCI_FPD1_BRIDGES) {FPD_CCI_NOC0 0 FPD_CCI_NOC1 0 FPD_CCI_NOC2 0 FPD_CCI_NOC3 0 FPD_AXI_PL 0 LPD_AXI_PL 0} \
    CONFIG.PS_PMC_CONFIG(PS_NOC_CCI_FPD_DATA_WIDTH) {128} \
    CONFIG.PS_PMC_CONFIG(PS_NUM_F2P0_INTR_INPUTS) {1} \
    CONFIG.PS_PMC_CONFIG(PS_NUM_F2P1_INTR_INPUTS) {1} \
    CONFIG.PS_PMC_CONFIG(PS_NUM_FABRIC_RESETS) {4} \
    CONFIG.PS_PMC_CONFIG(PS_OCM_ACTIVE_BLOCKS) {1} \
    CONFIG.PS_PMC_CONFIG(PS_PCIE_PERIPHERAL_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_PCIE_RESET) {ENABLE 0 IO PS_MIO_18:19} \
    CONFIG.PS_PMC_CONFIG(PS_PCIE_ROOT_RESET1_POLARITY) {Active_Low} \
    CONFIG.PS_PMC_CONFIG(PS_PCIE_ROOT_RESET2_POLARITY) {Active_Low} \
    CONFIG.PS_PMC_CONFIG(PS_PL_ACE_FPD_BRIDGES) {FPD_CCI_NOC0 0 FPD_CCI_NOC1 0 FPD_CCI_NOC2 0 FPD_CCI_NOC3 0 FPD_AXI_PL 0 LPD_AXI_PL 0} \
    CONFIG.PS_PMC_CONFIG(PS_PL_ACE_FPD_DATA_WIDTH) {128} \
    CONFIG.PS_PMC_CONFIG(PS_PL_ACP_FPD_BRIDGES) {FPD_CCI_NOC0 0 FPD_CCI_NOC1 0 FPD_CCI_NOC2 0 FPD_CCI_NOC3 0 FPD_AXI_PL 0 LPD_AXI_PL 0} \
    CONFIG.PS_PMC_CONFIG(PS_PL_ACP_FPD_DATA_WIDTH) {128} \
    CONFIG.PS_PMC_CONFIG(PS_PL_AXI_FPD0_BRIDGES) {FPD_AXI_NOC0 0 FPD_AXI_PL 0 LPD_AXI_PL 0} \
    CONFIG.PS_PMC_CONFIG(PS_PL_AXI_FPD2_BRIDGES) {FPD_CCI_NOC0 0 FPD_CCI_NOC1 0 FPD_CCI_NOC2 0 FPD_CCI_NOC3 0 FPD_AXI_PL 0 LPD_AXI_PL 0} \
    CONFIG.PS_PMC_CONFIG(PS_PL_AXI_LPD_BRIDGES) {FPD_AXI_PL 0 LPD_AXI_PL 0 LPD_AXI_NOC0 0} \
    CONFIG.PS_PMC_CONFIG(PS_PL_CCI_FPD_BRIDGES) {FPD_CCI_NOC0 0 FPD_CCI_NOC1 0 FPD_CCI_NOC2 0 FPD_CCI_NOC3 0 FPD_AXI_PL 0 LPD_AXI_PL 0} \
    CONFIG.PS_PMC_CONFIG(PS_PL_DONE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_PL_PASS_AXPROT_VALUE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_PMCPL_CLK0_BUF) {1} \
    CONFIG.PS_PMC_CONFIG(PS_PMCPL_CLK1_BUF) {1} \
    CONFIG.PS_PMC_CONFIG(PS_PMCPL_CLK2_BUF) {1} \
    CONFIG.PS_PMC_CONFIG(PS_PMCPL_CLK3_BUF) {1} \
    CONFIG.PS_PMC_CONFIG(PS_PMC_AXI_NOC_DATA_WIDTH) {128} \
    CONFIG.PS_PMC_CONFIG(PS_PMU_PERIPHERAL_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_PS_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_R5_ACTIVE_BLOCKS) {2} \
    CONFIG.PS_PMC_CONFIG(PS_R5_LOAD) {90} \
    CONFIG.PS_PMC_CONFIG(PS_RED_KEY_CLEAR_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_RPU_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_SLR_ID) {0} \
    CONFIG.PS_PMC_CONFIG(PS_SLR_TYPE) {master} \
    CONFIG.PS_PMC_CONFIG(PS_SMON_PL_PORTS_ENABLE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_SPI0) {GRP_SS0_ENABLE 0 GRP_SS0_IO PMC_MIO_15 GRP_SS1_ENABLE 0 GRP_SS1_IO PMC_MIO_14 GRP_SS2_ENABLE 0 GRP_SS2_IO PMC_MIO_13 PERIPHERAL_ENABLE 0 PERIPHERAL_IO PMC_MIO_12:17 IO_TYPE\
MIO} \
    CONFIG.PS_PMC_CONFIG(PS_SPI1) {GRP_SS0_ENABLE 0 GRP_SS0_IO PMC_MIO_35 GRP_SS1_ENABLE 0 GRP_SS1_IO PMC_MIO_34 GRP_SS2_ENABLE 0 GRP_SS2_IO PMC_MIO_33 PERIPHERAL_ENABLE 0 PERIPHERAL_IO PMC_MIO_32:37 IO_TYPE\
MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TCM_ACTIVE_BLOCKS) {2} \
    CONFIG.PS_PMC_CONFIG(PS_TIE_MJTAG_TCK_TO_GND) {1} \
    CONFIG.PS_PMC_CONFIG(PS_TRACE_PERIPHERAL) {ENABLE 0 IO PMC_MIO_30:47 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TRISTATE_INVERTED) {1} \
    CONFIG.PS_PMC_CONFIG(PS_TTC0_CLK) {ENABLE 0 IO PMC_MIO_6 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TTC0_PERIPHERAL_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_TTC0_WAVEOUT) {ENABLE 0 IO PMC_MIO_7 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TTC1_CLK) {ENABLE 0 IO PMC_MIO_12 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TTC1_PERIPHERAL_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_TTC1_WAVEOUT) {ENABLE 0 IO PMC_MIO_13 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TTC2_CLK) {ENABLE 0 IO PMC_MIO_2 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TTC2_PERIPHERAL_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_TTC2_WAVEOUT) {ENABLE 0 IO PMC_MIO_3 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TTC3_CLK) {ENABLE 0 IO PMC_MIO_16 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TTC3_PERIPHERAL_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_TTC3_WAVEOUT) {ENABLE 0 IO PMC_MIO_17 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TTC_APB_CLK_TTC0_SEL) {APB} \
    CONFIG.PS_PMC_CONFIG(PS_TTC_APB_CLK_TTC1_SEL) {APB} \
    CONFIG.PS_PMC_CONFIG(PS_TTC_APB_CLK_TTC2_SEL) {APB} \
    CONFIG.PS_PMC_CONFIG(PS_TTC_APB_CLK_TTC3_SEL) {APB} \
    CONFIG.PS_PMC_CONFIG(PS_UART0_BAUD_RATE) {115200} \
    CONFIG.PS_PMC_CONFIG(PS_UART0_PERIPHERAL) {ENABLE 1 IO EMIO IO_TYPE EMIO} \
    CONFIG.PS_PMC_CONFIG(PS_UART0_RTS_CTS) {ENABLE 0 IO PMC_MIO_2:3 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_UART1_BAUD_RATE) {115200} \
    CONFIG.PS_PMC_CONFIG(PS_UART1_PERIPHERAL) {ENABLE 1 IO EMIO IO_TYPE EMIO} \
    CONFIG.PS_PMC_CONFIG(PS_UART1_RTS_CTS) {ENABLE 0 IO PMC_MIO_6:7 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_USB3_PERIPHERAL) {ENABLE 1 IO PMC_MIO_13:25 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_USB_COHERENCY) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USB_ROUTE_THROUGH_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_APU_EVENT_BUS) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_APU_INTERRUPT) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_AXI4_EXT_USER_BITS) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_BSCAN_USER1) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_BSCAN_USER2) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_BSCAN_USER3) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_BSCAN_USER4) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_CAPTURE) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_CLK) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_DEBUG_TEST) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_DIFF_RW_CLK_PL_AXI_FPD0) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_DIFF_RW_CLK_PL_AXI_FPD2) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_DIFF_RW_CLK_PL_AXI_LPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_ENET1_PTP) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FIFO_ENET1) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FIXED_IO) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FPD_AXI_NOC0) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FPD_AXI_NOC1) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FPD_AXI_PL) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FPD_CCI_NOC) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FTM_GPI) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FTM_GPO) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_HSDP_PL) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_LPD_AXI_NOC0) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_LPD_AXI_PL) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_MJTAG_TCK_TIE_OFF) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_NOC_AXI_FPD0) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_NOC_AXI_FPD1) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_NOC_CCI_FPD0) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_NOC_CCI_FPD1) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_NOC_PS_PMC_0) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_NPI_CLK) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_NPI_RST) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PL_ACE_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PL_ACP_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PL_AXI_FPD0) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PL_AXI_FPD2) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PL_AXI_LPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PL_FPD_AUX_REF_CLK) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PL_LPD_AUX_REF_CLK) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PMC) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PMCPL_CLK0) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PMCPL_CLK1) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PMCPL_CLK2) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PMCPL_CLK3) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PMCPL_IRO_CLK) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PSPL_IRQ_FPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PSPL_IRQ_LPD) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PSPL_IRQ_PMC) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_RPU_EVENT) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_RPU_INTERRUPT) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_RTC) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_SMMU) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_STARTUP) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_STM) {0} \
    CONFIG.PS_PMC_CONFIG(PS_USE_TRACE_ATB) {0} \
    CONFIG.PS_PMC_CONFIG(PS_WDT0_REF_CTRL_ACT_FREQMHZ) {100} \
    CONFIG.PS_PMC_CONFIG(PS_WDT0_REF_CTRL_FREQMHZ) {100} \
    CONFIG.PS_PMC_CONFIG(PS_WDT0_REF_CTRL_SEL) {NONE} \
    CONFIG.PS_PMC_CONFIG(PS_WDT1_REF_CTRL_ACT_FREQMHZ) {100} \
    CONFIG.PS_PMC_CONFIG(PS_WDT1_REF_CTRL_FREQMHZ) {100} \
    CONFIG.PS_PMC_CONFIG(PS_WDT1_REF_CTRL_SEL) {NONE} \
    CONFIG.PS_PMC_CONFIG(PS_WWDT0_CLK) {ENABLE 0 IO PMC_MIO_0 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_WWDT0_PERIPHERAL) {ENABLE 0 IO PMC_MIO_0:5 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_WWDT1_CLK) {ENABLE 0 IO PMC_MIO_6 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_WWDT1_PERIPHERAL) {ENABLE 0 IO PMC_MIO_6:11 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(SEM_MEM_GOLDEN_ECC) {0} \
    CONFIG.PS_PMC_CONFIG(SEM_MEM_SCAN) {0} \
    CONFIG.PS_PMC_CONFIG(SEM_NPI_SCAN) {0} \
    CONFIG.PS_PMC_CONFIG(SMON_ALARMS) {Set_Alarms_On} \
    CONFIG.PS_PMC_CONFIG(SMON_ENABLE_INT_VOLTAGE_MONITORING) {0} \
    CONFIG.PS_PMC_CONFIG(SMON_ENABLE_TEMP_AVERAGING) {0} \
    CONFIG.PS_PMC_CONFIG(SMON_HI_PERF_MODE) {1} \
    CONFIG.PS_PMC_CONFIG(SMON_INTERFACE_TO_USE) {None} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS0) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCCAUX_110 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS1) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCCAUX_111 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS10) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCC_112 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS100) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_118 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS101) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_119 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS102) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_120 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS103) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_121 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS104) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_202 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS105) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_203 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS106) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_204 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS107) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_205 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS108) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_206 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS109) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_207 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS11) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCC_113 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS110) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_208 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS111) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_209 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS112) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_214 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS113) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_215 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS114) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_216 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS115) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_217 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS116) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_218 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS117) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_219 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS118) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_220 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS119) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_221 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS12) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCC_210 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS120) {ENABLE 0 MODE 2V_unipolar NAME VCCAUX AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS121) {ENABLE 0 MODE 2V_unipolar NAME VCCAUX_PMC AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS122) {ENABLE 0 MODE 2V_unipolar NAME VCCAUX_SMON AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS123) {ENABLE 0 MODE 2V_unipolar NAME VCCINT AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS124) {ENABLE 0 MODE 4V_unipolar NAME VCCO_308 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 4.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS125) {ENABLE 0 MODE 4V_unipolar NAME VCCO_315 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 4.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS126) {ENABLE 0 MODE 4V_unipolar NAME VCCO_408 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 4.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS127) {ENABLE 0 MODE 4V_unipolar NAME VCCO_415 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 4.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS128) {ENABLE 0 MODE 4V_unipolar NAME VCCO_500 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 4.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS129) {ENABLE 0 MODE 4V_unipolar NAME VCCO_501 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 4.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS13) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCC_211 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS130) {ENABLE 0 MODE 4V_unipolar NAME VCCO_503 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 4.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS131) {ENABLE 0 MODE 2V_unipolar NAME VCCO_700 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS132) {ENABLE 0 MODE 2V_unipolar NAME VCCO_701 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS133) {ENABLE 0 MODE 2V_unipolar NAME VCCO_702 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS134) {ENABLE 0 MODE 2V_unipolar NAME VCCO_703 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS135) {ENABLE 0 MODE 2V_unipolar NAME VCCO_704 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS136) {ENABLE 0 MODE 2V_unipolar NAME VCCO_705 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS137) {ENABLE 0 MODE 2V_unipolar NAME VCCO_706 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS138) {ENABLE 0 MODE 2V_unipolar NAME VCCO_707 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS139) {ENABLE 0 MODE 2V_unipolar NAME VCCO_708 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS14) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCC_212 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS140) {ENABLE 0 MODE 2V_unipolar NAME VCCO_709 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS141) {ENABLE 0 MODE 2V_unipolar NAME VCCO_710 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS142) {ENABLE 0 MODE 2V_unipolar NAME VCCO_711 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS143) {ENABLE 0 MODE 2V_unipolar NAME VCCO_712 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS144) {ENABLE 0 MODE 2V_unipolar NAME VCCO_713 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS145) {ENABLE 0 MODE 2V_unipolar NAME VCCO_714 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS146) {ENABLE 0 MODE 2V_unipolar NAME VCCO_715 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS147) {ENABLE 0 MODE 2V_unipolar NAME VCCO_716 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS148) {ENABLE 0 MODE 2V_unipolar NAME VCCO_717 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS149) {ENABLE 0 MODE 2V_unipolar NAME VCCO_718 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS15) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCC_213 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS150) {ENABLE 0 MODE 2V_unipolar NAME VCCO_719 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS151) {ENABLE 0 MODE 2V_unipolar NAME VCCO_720 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS152) {ENABLE 0 MODE 2V_unipolar NAME VCCO_721 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS153) {ENABLE 0 MODE 2V_unipolar NAME VCCO_722 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS154) {ENABLE 0 MODE 2V_unipolar NAME VCCO_723 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS155) {ENABLE 0 MODE 2V_unipolar NAME VCCO_800 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS156) {ENABLE 0 MODE 2V_unipolar NAME VCCO_801 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS157) {ENABLE 0 MODE 2V_unipolar NAME VCCO_802 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS158) {ENABLE 0 MODE 2V_unipolar NAME VCCO_803 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS159) {ENABLE 0 MODE 2V_unipolar NAME VCCO_804 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS16) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVTT_110 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS160) {ENABLE 0 MODE 2V_unipolar NAME VCCO_805 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS161) {ENABLE 0 MODE 2V_unipolar NAME VCCO_806 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS162) {ENABLE 0 MODE 2V_unipolar NAME VCCO_807 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS163) {ENABLE 0 MODE 2V_unipolar NAME VCCO_808 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS164) {ENABLE 0 MODE 2V_unipolar NAME VCCO_809 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS165) {ENABLE 0 MODE 2V_unipolar NAME VCCO_810 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS166) {ENABLE 0 MODE 2V_unipolar NAME VCCO_811 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS167) {ENABLE 0 MODE 2V_unipolar NAME VCCO_812 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS168) {ENABLE 0 MODE 2V_unipolar NAME VCCO_813 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS169) {ENABLE 0 MODE 2V_unipolar NAME VCCO_814 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS17) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVTT_111 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS170) {ENABLE 0 MODE 2V_unipolar NAME VCCO_815 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS171) {ENABLE 0 MODE 2V_unipolar NAME VCCO_816 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS172) {ENABLE 0 MODE 2V_unipolar NAME VCCO_817 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS173) {ENABLE 0 MODE 2V_unipolar NAME VCCO_818 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS174) {ENABLE 0 MODE 2V_unipolar NAME VCCO_819 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS175) {ENABLE 0 MODE 2V_unipolar NAME VCCO_820 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS176) {ENABLE 0 MODE 2V_unipolar NAME VCCO_821 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS177) {ENABLE 0 MODE 2V_unipolar NAME VCCO_822 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS178) {ENABLE 0 MODE 2V_unipolar NAME VCCO_823 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS179) {ENABLE 0 MODE 2V_unipolar NAME VCC_BATT AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS18) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVTT_112 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS180) {ENABLE 0 MODE 2V_unipolar NAME VCC_PMC AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS181) {ENABLE 0 MODE 2V_unipolar NAME VCC_PSFP AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS182) {ENABLE 0 MODE 2V_unipolar NAME VCC_PSLP AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS183) {ENABLE 0 MODE 2V_unipolar NAME VCC_RAM AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS184) {ENABLE 0 MODE 2V_unipolar NAME VCC_SOC AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS185) {ENABLE 0 MODE 1V_unipolar NAME VP_VN AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 1.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS186) {ENABLE 0 MODE None NAME GT_AVAUX_PKG_103 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS19) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVTT_113 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS2) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCCAUX_112 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS20) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVTT_210 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS21) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVTT_211 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS22) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVTT_212 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS23) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVTT_213 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS24) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_102 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS25) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_103 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS26) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_104 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS27) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_105 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS28) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_106 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS29) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_107 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS3) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCCAUX_113 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS30) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_108 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS31) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_109 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS32) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_114 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS33) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_115 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS34) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_116 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS35) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_117 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS36) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_118 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS37) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_119 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS38) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_120 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS39) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_121 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS4) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCCAUX_210 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS40) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_202 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS41) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_203 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS42) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_204 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS43) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_205 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS44) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_206 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS45) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_207 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS46) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_208 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS47) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_209 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS48) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_214 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS49) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_215 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS5) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCCAUX_211 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS50) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_216 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS51) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_217 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS52) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_218 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS53) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_219 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS54) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_220 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS55) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCCAUX_221 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS56) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_102 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS57) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_103 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS58) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_104 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS59) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_105 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS6) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCCAUX_212 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS60) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_106 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS61) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_107 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS62) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_108 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS63) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_109 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS64) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_114 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS65) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_115 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS66) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_116 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS67) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_117 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS68) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_118 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS69) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_119 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS7) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCCAUX_213 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS70) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_120 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS71) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_121 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS72) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_202 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS73) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_203 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS74) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_204 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS75) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_205 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS76) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_206 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS77) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_207 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS78) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_208 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS79) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_209 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS8) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCC_110 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS80) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_214 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS81) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_215 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS82) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_216 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS83) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_217 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS84) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_218 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS85) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_219 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS86) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_220 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS87) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVCC_221 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS88) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_102 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS89) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_103 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS9) {ENABLE 0 MODE 2V_unipolar NAME GTM_AVCC_111 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS90) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_104 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS91) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_105 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS92) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_106 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS93) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_107 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS94) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_108 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS95) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_109 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS96) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_114 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS97) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_115 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS98) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_116 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEAS99) {ENABLE 0 MODE 2V_unipolar NAME GTYP_AVTT_117 AVERAGE_EN 0 ALARM_ENABLE 0 ALARM_LOWER 0.00 ALARM_UPPER 2.00 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_MEASUREMENT_COUNT) {186} \
    CONFIG.PS_PMC_CONFIG(SMON_MEASUREMENT_LIST) {BANK_VOLTAGE:GTM_AVTT-GTM_AVTT_110,GTM_AVTT_111,GTM_AVTT_112,GTM_AVTT_113,GTM_AVTT_210,GTM_AVTT_211,GTM_AVTT_212,GTM_AVTT_213#GTYP_AVTT-GTYP_AVTT_102,GTYP_AVTT_103,GTYP_AVTT_104,GTYP_AVTT_105,GTYP_AVTT_106,GTYP_AVTT_107,GTYP_AVTT_108,GTYP_AVTT_109,GTYP_AVTT_114,GTYP_AVTT_115,GTYP_AVTT_116,GTYP_AVTT_117,GTYP_AVTT_118,GTYP_AVTT_119,GTYP_AVTT_120,GTYP_AVTT_121,GTYP_AVTT_202,GTYP_AVTT_203,GTYP_AVTT_204,GTYP_AVTT_205,GTYP_AVTT_206,GTYP_AVTT_207,GTYP_AVTT_208,GTYP_AVTT_209,GTYP_AVTT_214,GTYP_AVTT_215,GTYP_AVTT_216,GTYP_AVTT_217,GTYP_AVTT_218,GTYP_AVTT_219,GTYP_AVTT_220,GTYP_AVTT_221#VCC-GTM_AVCC_110,GTM_AVCC_111,GTM_AVCC_112,GTM_AVCC_113,GTM_AVCC_210,GTM_AVCC_211,GTM_AVCC_212,GTM_AVCC_213,GTYP_AVCC_102,GTYP_AVCC_103,GTYP_AVCC_104,GTYP_AVCC_105,GTYP_AVCC_106,GTYP_AVCC_107,GTYP_AVCC_108,GTYP_AVCC_109,GTYP_AVCC_114,GTYP_AVCC_115,GTYP_AVCC_116,GTYP_AVCC_117,GTYP_AVCC_118,GTYP_AVCC_119,GTYP_AVCC_120,GTYP_AVCC_121,GTYP_AVCC_202,GTYP_AVCC_203,GTYP_AVCC_204,GTYP_AVCC_205,GTYP_AVCC_206,GTYP_AVCC_207,GTYP_AVCC_208,GTYP_AVCC_209,GTYP_AVCC_214,GTYP_AVCC_215,GTYP_AVCC_216,GTYP_AVCC_217,GTYP_AVCC_218,GTYP_AVCC_219,GTYP_AVCC_220,GTYP_AVCC_221#VCCAUX-GTM_AVCCAUX_110,GTM_AVCCAUX_111,GTM_AVCCAUX_112,GTM_AVCCAUX_113,GTM_AVCCAUX_210,GTM_AVCCAUX_211,GTM_AVCCAUX_212,GTM_AVCCAUX_213,GTYP_AVCCAUX_102,GTYP_AVCCAUX_103,GTYP_AVCCAUX_104,GTYP_AVCCAUX_105,GTYP_AVCCAUX_106,GTYP_AVCCAUX_107,GTYP_AVCCAUX_108,GTYP_AVCCAUX_109,GTYP_AVCCAUX_114,GTYP_AVCCAUX_115,GTYP_AVCCAUX_116,GTYP_AVCCAUX_117,GTYP_AVCCAUX_118,GTYP_AVCCAUX_119,GTYP_AVCCAUX_120,GTYP_AVCCAUX_121,GTYP_AVCCAUX_202,GTYP_AVCCAUX_203,GTYP_AVCCAUX_204,GTYP_AVCCAUX_205,GTYP_AVCCAUX_206,GTYP_AVCCAUX_207,GTYP_AVCCAUX_208,GTYP_AVCCAUX_209,GTYP_AVCCAUX_214,GTYP_AVCCAUX_215,GTYP_AVCCAUX_216,GTYP_AVCCAUX_217,GTYP_AVCCAUX_218,GTYP_AVCCAUX_219,GTYP_AVCCAUX_220,GTYP_AVCCAUX_221#VCCO-VCCO_308,VCCO_315,VCCO_408,VCCO_415,VCCO_500,VCCO_501,VCCO_503,VCCO_700,VCCO_701,VCCO_702,VCCO_703,VCCO_704,VCCO_705,VCCO_706,VCCO_707,VCCO_708,VCCO_709,VCCO_710,VCCO_711,VCCO_712,VCCO_713,VCCO_714,VCCO_715,VCCO_716,VCCO_717,VCCO_718,VCCO_719,VCCO_720,VCCO_721,VCCO_722,VCCO_723,VCCO_800,VCCO_801,VCCO_802,VCCO_803,VCCO_804,VCCO_805,VCCO_806,VCCO_807,VCCO_808,VCCO_809,VCCO_810,VCCO_811,VCCO_812,VCCO_813,VCCO_814,VCCO_815,VCCO_816,VCCO_817,VCCO_818,VCCO_819,VCCO_820,VCCO_821,VCCO_822,VCCO_823|DEDICATED_PAD:VP-VP_VN|SUPPLY_VOLTAGE:VCC-VCC_BATT,VCC_PMC,VCC_PSFP,VCC_PSLP,VCC_RAM,VCC_SOC#VCCAUX-VCCAUX,VCCAUX_PMC,VCCAUX_SMON#VCCINT-VCCINT}\
\
    CONFIG.PS_PMC_CONFIG(SMON_OT) {THRESHOLD_LOWER 70 THRESHOLD_UPPER 125} \
    CONFIG.PS_PMC_CONFIG(SMON_REFERENCE_SOURCE) {Internal} \
    CONFIG.PS_PMC_CONFIG(SMON_TEMP_THRESHOLD) {0} \
    CONFIG.PS_PMC_CONFIG(SMON_USER_TEMP) {USER_ALARM_TYPE hysteresis THRESHOLD_LOWER 70 THRESHOLD_UPPER 125} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH0) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH0 IO_P PMC_MIO1_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH1) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH1 IO_P PMC_MIO2_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH10) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH10 IO_P PMC_MIO11_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH11) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH11 IO_P PMC_MIO12_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH12) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH12 IO_P PMC_MIO13_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH13) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH13 IO_P PMC_MIO14_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH14) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH14 IO_P PMC_MIO15_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH15) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH15 IO_P PMC_MIO16_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH2) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH2 IO_P PMC_MIO3_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH3) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH3 IO_P PMC_MIO4_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH4) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH4 IO_P PMC_MIO5_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH5) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH5 IO_P PMC_MIO6_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH6) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH6 IO_P PMC_MIO7_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH7) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH7 IO_P PMC_MIO8_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH8) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH8 IO_P PMC_MIO9_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_CH9) {ENABLE 0 MODE 1V_unipolar NAME VAUX_CH9 IO_P PMC_MIO10_500 IO_N PMC_MIO0_500 ALARM_ENABLE 0 AVERAGE_EN 0 ALARM_LOWER 0 ALARM_UPPER 1 SUPPLY_NUM 0} \
    CONFIG.PS_PMC_CONFIG(SMON_VAUX_IO_BANK) {MIO_BANK0} \
    CONFIG.PS_PMC_CONFIG(SMON_VOLTAGE_AVERAGING_SAMPLES) {None} \
    CONFIG.PS_PMC_CONFIG(SPP_PSPMC_FROM_CORE_WIDTH) {12000} \
    CONFIG.PS_PMC_CONFIG(SPP_PSPMC_TO_CORE_WIDTH) {12000} \
    CONFIG.PS_PMC_CONFIG(SUBPRESET1) {Custom} \
    CONFIG.PS_PMC_CONFIG(USE_UART0_IN_DEVICE_BOOT) {0} \
    CONFIG.PS_PMC_CONFIG(preset) {None} \
    CONFIG.PS_PMC_CONFIG_APPLIED {1} \
  ] $ps_wizard_0


  # Create instance: ddr4_c2, and set properties


  # Create instance: csi_axi_gpio_1, and set properties


  # Create instance: csi_cap_pipe

  # Create instance: clk_wizard_1, and set properties







  # Create instance: csi_mipi_csi_rx_ss







  # Create instance: hdmi_axi_iic_0, and set properties

  # Create instance: ilconstant_2, and set properties
  set ilconstant_2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_2 ]

  # Create instance: clk_wizard_2, and set properties


  # Create instance: ilconstant_3, and set properties
  set ilconstant_3 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_3 ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_3


  # Create instance: hdmi_axi_timer_0, and set properties


  # Create instance: proc_sysrst4, and set properties

  # Create instance: hdmi_axi_timer_1, and set properties


  # Create instance: hdmi_hier_0

  # Create instance: hsdp_soft_aurora

  # Create instance: axi_dbg_hub_0, and set properties

  # Create interface connections
  connect_bd_intf_net -intf_net axi_noc_0_CH0_DDR4_0 [get_bd_intf_ports C0_DDR4] [get_bd_intf_pins axi_noc_0/CH0_DDR4_0]
  connect_bd_intf_net -intf_net axi_noc_0_CH0_DDR4_1 [get_bd_intf_ports C1_DDR4] [get_bd_intf_pins axi_noc_0/CH0_DDR4_1]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_CCI_NOC0 [get_bd_intf_pins axi_noc_0/S01_AXI] [get_bd_intf_pins ps_wizard_0/FPD_CCI_NOC0]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_CCI_NOC1 [get_bd_intf_pins axi_noc_0/S02_AXI] [get_bd_intf_pins ps_wizard_0/FPD_CCI_NOC1]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_CCI_NOC2 [get_bd_intf_pins axi_noc_0/S03_AXI] [get_bd_intf_pins ps_wizard_0/FPD_CCI_NOC2]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_CCI_NOC3 [get_bd_intf_pins axi_noc_0/S04_AXI] [get_bd_intf_pins ps_wizard_0/FPD_CCI_NOC3]
  connect_bd_intf_net -intf_net ps_wizard_0_GEM1_MDIO [get_bd_intf_ports GEM1_MDIO] [get_bd_intf_pins ps_wizard_0/GEM1_MDIO]
  connect_bd_intf_net -intf_net ps_wizard_0_I2C0 [get_bd_intf_ports I2C0] [get_bd_intf_pins ps_wizard_0/I2C0]
  connect_bd_intf_net -intf_net ps_wizard_0_I2C1 [get_bd_intf_ports I2C1] [get_bd_intf_pins ps_wizard_0/I2C1]
  connect_bd_intf_net -intf_net ps_wizard_0_LPD_AXI_NOC0 [get_bd_intf_pins axi_noc_0/S05_AXI] [get_bd_intf_pins ps_wizard_0/LPD_AXI_NOC0]
  connect_bd_intf_net -intf_net ps_wizard_0_PMC_AXI_NOC0 [get_bd_intf_pins axi_noc_0/S00_AXI] [get_bd_intf_pins ps_wizard_0/PMC_AXI_NOC0]
  connect_bd_intf_net -intf_net ps_wizard_0_UART0 [get_bd_intf_ports UART0] [get_bd_intf_pins ps_wizard_0/UART0]
  connect_bd_intf_net -intf_net ps_wizard_0_UART1 [get_bd_intf_ports UART1] [get_bd_intf_pins ps_wizard_0/UART1]
  connect_bd_intf_net -intf_net sys_clk0_0_1 [get_bd_intf_ports C0_DDR4_SYS] [get_bd_intf_pins axi_noc_0/sys_clk0]
  connect_bd_intf_net -intf_net sys_clk1_0_1 [get_bd_intf_ports C1_DDR4_SYS] [get_bd_intf_pins axi_noc_0/sys_clk1]
  connect_bd_intf_net -intf_net versal_cips_0_FPD_AXI_PL [get_bd_intf_pins ps_wizard_0/FPD_AXI_PL] [get_bd_intf_pins axi_smc/S00_AXI]

  # Create port connections
  connect_bd_net -net clk_wizard_0_locked  [get_bd_pins clk_wizard_0/locked] \
  [get_bd_pins proc_sys_reset_1/dcm_locked]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn  [get_bd_pins proc_sys_reset_0/interconnect_aresetn] \
  [get_bd_pins axi_smc/aresetn]
  connect_bd_net -net ps_wizard_0_fpd_cci_noc0_clk  [get_bd_pins ps_wizard_0/fpd_cci_noc0_clk] \
  [get_bd_pins axi_noc_0/aclk1]
  connect_bd_net -net ps_wizard_0_fpd_cci_noc1_clk  [get_bd_pins ps_wizard_0/fpd_cci_noc1_clk] \
  [get_bd_pins axi_noc_0/aclk2]
  connect_bd_net -net ps_wizard_0_fpd_cci_noc2_clk  [get_bd_pins ps_wizard_0/fpd_cci_noc2_clk] \
  [get_bd_pins axi_noc_0/aclk3]
  connect_bd_net -net ps_wizard_0_fpd_cci_noc3_clk  [get_bd_pins ps_wizard_0/fpd_cci_noc3_clk] \
  [get_bd_pins axi_noc_0/aclk4]
  connect_bd_net -net ps_wizard_0_lpd_axi_noc0_clk  [get_bd_pins ps_wizard_0/lpd_axi_noc0_clk] \
  [get_bd_pins axi_noc_0/aclk5]
  connect_bd_net -net ps_wizard_0_pl3_ref_clk  [get_bd_pins ps_wizard_0/pl3_ref_clk] \
  [get_bd_pins axi_noc_0/aclk9]
  connect_bd_net -net ps_wizard_0_pmc_axi_noc0_clk  [get_bd_pins ps_wizard_0/pmc_axi_noc0_clk] \
  [get_bd_pins axi_noc_0/aclk0]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs axi_noc_0/S01_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x00C000000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs axi_noc_0/S01_AXI/C0_DDR_LOW2x2] -force
  assign_bd_address -offset 0x60000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs axi_noc_0/S04_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x20000000 -range 0x20000000 -with_name SEG_axi_noc_0_C1_DDR_LOW0x2_1 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs axi_noc_0/S02_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x40000000 -range 0x20000000 -with_name SEG_axi_noc_0_C1_DDR_LOW0x2_2 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x00C600000000 -range 0x000980000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs axi_noc_0/S04_AXI/C1_DDR_LOW2x2] -force
  assign_bd_address -offset 0x00C200000000 -range 0x000200000000 -with_name SEG_axi_noc_0_C1_DDR_LOW2x2_1 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs axi_noc_0/S02_AXI/C1_DDR_LOW2x2] -force
  assign_bd_address -offset 0x00C400000000 -range 0x000200000000 -with_name SEG_axi_noc_0_C1_DDR_LOW2x2_2 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW2x2] -force
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs axi_noc_0/S01_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x00C000000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs axi_noc_0/S01_AXI/C0_DDR_LOW2x2] -force
  assign_bd_address -offset 0x60000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs axi_noc_0/S04_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x20000000 -range 0x20000000 -with_name SEG_axi_noc_0_C1_DDR_LOW0x2_1 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs axi_noc_0/S02_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x40000000 -range 0x20000000 -with_name SEG_axi_noc_0_C1_DDR_LOW0x2_2 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x00C600000000 -range 0x000980000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs axi_noc_0/S04_AXI/C1_DDR_LOW2x2] -force
  assign_bd_address -offset 0x00C200000000 -range 0x000200000000 -with_name SEG_axi_noc_0_C1_DDR_LOW2x2_1 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs axi_noc_0/S02_AXI/C1_DDR_LOW2x2] -force
  assign_bd_address -offset 0x00C400000000 -range 0x000200000000 -with_name SEG_axi_noc_0_C1_DDR_LOW2x2_2 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW2x2] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x50000000 -range 0x10000000 -with_name SEG_axi_noc_0_C0_DDR_LOW0x2_1 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S05_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x10000000 -range 0x10000000 -with_name SEG_axi_noc_0_C0_DDR_LOW0x2_2 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S01_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x40000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S04_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x20000000 -range 0x10000000 -with_name SEG_axi_noc_0_C1_DDR_LOW0x2_1 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S02_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x30000000 -range 0x10000000 -with_name SEG_axi_noc_0_C1_DDR_LOW0x2_2 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x50000000 -range 0x10000000 -with_name SEG_axi_noc_0_C0_DDR_LOW0x2_1 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S05_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x10000000 -range 0x10000000 -with_name SEG_axi_noc_0_C0_DDR_LOW0x2_2 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S01_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x40000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S04_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x20000000 -range 0x10000000 -with_name SEG_axi_noc_0_C1_DDR_LOW0x2_1 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S02_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x30000000 -range 0x10000000 -with_name SEG_axi_noc_0_C1_DDR_LOW0x2_2 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW0x2] -force
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_dpc_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x00C000000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_dpc_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW2x2] -force
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_pmc_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x00C000000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_pmc_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW2x2] -force
  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW0x2] -force
  assign_bd_address -offset 0x40000000 -range 0x40000000 -with_name SEG_axi_noc_0_C0_DDR_LOW0x2_1 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs axi_noc_0/S05_AXI/C0_DDR_LOW0x2] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S05_AXI/C0_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S01_AXI/C0_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S04_AXI/C1_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S02_AXI/C1_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S05_AXI/C0_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S01_AXI/C0_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S04_AXI/C1_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S02_AXI/C1_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW2x2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs axi_noc_0/S05_AXI/C0_DDR_LOW2x2]


  # Restore current instance
  current_bd_instance $oldCurInst


  ############################################################
  # huins_vp1902_base platform intent (vck190-CED style)
  ############################################################

  ############################################################
  # huins_vp1902_base platform intent (vck190-CED style)
  ############################################################

  # --- Kernel clocks: reconfigure clk_wizard_0 (input pl0_ref_clk 100MHz)
  set_property -dict [list \
    CONFIG.CLKOUT_USED {true,true,true,true,true,true,false} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {100,200,300,400,600,156.25,100} \
    CONFIG.PRIM_IN_FREQ {99.999001} \
  ] $clk_wizard_0

  # --- Extra proc_sys_reset cells for kernel clocks
  set proc_sys_reset_3x [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_3x ]
  set proc_sys_reset_4x [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_4x ]
  set proc_sys_reset_5x [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_5x ]
  set proc_sys_reset_6x [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_6x ]
  connect_bd_net -net clk_wiz_clk_out2 [get_bd_pins clk_wizard_0/clk_out2] [get_bd_pins proc_sys_reset_3x/slowest_sync_clk]
  connect_bd_net -net clk_wiz_clk_out3 [get_bd_pins clk_wizard_0/clk_out3] [get_bd_pins proc_sys_reset_4x/slowest_sync_clk]
  connect_bd_net -net clk_wiz_clk_out4 [get_bd_pins clk_wizard_0/clk_out4] [get_bd_pins proc_sys_reset_5x/slowest_sync_clk]
  connect_bd_net -net clk_wiz_clk_out5 [get_bd_pins clk_wizard_0/clk_out5] [get_bd_pins proc_sys_reset_6x/slowest_sync_clk]
  connect_bd_net -net clk_wiz_clk_out1 [get_bd_pins clk_wizard_0/clk_out1] [get_bd_pins proc_sys_reset_2/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_locked [get_bd_pins proc_sys_reset_2/dcm_locked] \
    [get_bd_pins proc_sys_reset_3x/dcm_locked] [get_bd_pins proc_sys_reset_4x/dcm_locked] \
    [get_bd_pins proc_sys_reset_5x/dcm_locked] [get_bd_pins proc_sys_reset_6x/dcm_locked]
  connect_bd_net -net ps_wizard_0_pl0_resetn [get_bd_pins ps_wizard_0/pl0_resetn] \
    [get_bd_pins proc_sys_reset_0/ext_reset_in] \
    [get_bd_pins proc_sys_reset_1/ext_reset_in] [get_bd_pins proc_sys_reset_2/ext_reset_in] \
    [get_bd_pins proc_sys_reset_3x/ext_reset_in] [get_bd_pins proc_sys_reset_4x/ext_reset_in] \
    [get_bd_pins proc_sys_reset_5x/ext_reset_in] [get_bd_pins proc_sys_reset_6x/ext_reset_in]

  # --- Remove the NoC's PL-facing master port (PL DDR ddr4_c2 was stripped)
  set_property -dict [list CONFIG.NUM_MI {0}] $axi_noc_0
  # --- Kernel control path: keep only the fixed interrupt-controller master.
  # Vitis expands the PFM-declared M01..M15 ports when linking kernels.
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_CLKS {1}] $axi_smc
  # disable HSDP debug link (GT clocking stripped with the reference design)
  set_property -dict [list CONFIG.PS_PMC_CONFIG(PS_HSDP_INGRESS_TRAFFIC) {JTAG} \
    CONFIG.PS_PMC_CONFIG(PS_HSDP_SAME_EGRESS_AS_INGRESS_TRAFFIC) {1}] $ps_wizard_0
  # unified pl0_ref_clk net (100MHz) for control path + NoC aclks
  connect_bd_net -net ps_wizard_0_pl0_ref_clk [get_bd_pins ps_wizard_0/pl0_ref_clk] \
    [get_bd_pins clk_wizard_0/clk_in1] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
    [get_bd_pins proc_sys_reset_1/slowest_sync_clk] \
    [get_bd_pins axi_noc_0/aclk6] [get_bd_pins axi_noc_0/aclk7] [get_bd_pins axi_noc_0/aclk8] \
    [get_bd_pins axi_noc_0/aclk10] [get_bd_pins axi_noc_0/aclk11] \
    [get_bd_pins axi_smc/aclk] [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk] \
    [get_bd_pins axi_intc_0/s_axi_aclk]
  connect_bd_net -net hsdp_ref_clk [get_bd_pins clk_wizard_0/clk_out6] [get_bd_pins ps_wizard_0/hsdp_ref_clk]

  # --- Kernel interrupts: AXI INTC (32) -> pl_ps_irq0
  set axi_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc_0 ]
  set_property -dict [list CONFIG.C_ASYNC_INTR {0xFFFFFFFF} CONFIG.C_IRQ_CONNECTION {1} \
    CONFIG.C_IRQ_IS_LEVEL {1}] $axi_intc_0
  connect_bd_intf_net -intf_net axi_smc_M00_INTC [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins axi_intc_0/s_axi]
  connect_bd_net -net ps_wizard_0_pl0_ref_clk [get_bd_pins axi_intc_0/s_axi_aclk]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_intc_0/s_axi_aresetn]
  connect_bd_net -net axi_intc_0_irq [get_bd_pins axi_intc_0/irq] [get_bd_pins ps_wizard_0/pl_ps_irq0]
  assign_bd_address -offset 0xA4000000 -range 0x00001000 [get_bd_addr_segs axi_intc_0/S_AXI/Reg] -force

  # --- PFM properties
  set_property PFM_NAME "xilinx.com:huins:huins_vp1902_base:202520.1" [get_files [current_bd_design].bd]
  set_property PFM.CLOCK {clk_out1 {id "0" is_default "true" proc_sys_reset "proc_sys_reset_2" status "fixed"} \
    clk_out2 {id "1" is_default "false" proc_sys_reset "proc_sys_reset_3x" status "fixed"} \
    clk_out3 {id "2" is_default "false" proc_sys_reset "proc_sys_reset_4x" status "fixed"} \
    clk_out4 {id "3" is_default "false" proc_sys_reset "proc_sys_reset_5x" status "fixed"} \
    clk_out5 {id "4" is_default "false" proc_sys_reset "proc_sys_reset_6x" status "fixed"}} [get_bd_cells /clk_wizard_0]
  set parVal []
  for {set i 6} {$i < 10} {incr i} {
    lappend parVal S[format %02d $i]_AXI {memport "S_AXI_NOC" sptag "DDR"}
  }
  set_property PFM.AXI_PORT $parVal [get_bd_cells /axi_noc_0]
  # Declaring non-materialized ports avoids unused AXI transactors in hw_emu.
  set_property PFM.AXI_PORT {M01_AXI {} M02_AXI {} M03_AXI {} M04_AXI {} M05_AXI {} M06_AXI {} \
    M07_AXI {} M08_AXI {} M09_AXI {} M10_AXI {} M11_AXI {} M12_AXI {} M13_AXI {} M14_AXI {} \
    M15_AXI {}} [get_bd_cells /axi_smc]
  set_property PFM.IRQ {intr {id 0 range 32}} [get_bd_cells /axi_intc_0]

  # --- Platform properties
  set_property platform.default_output_type "sd_card" [current_project]
  set_property platform.design_intent.embedded "true" [current_project]
  set_property platform.extensible "true" [current_project]
  set_property platform.design_intent.server_managed "false" [current_project]
  set_property platform.design_intent.external_host "false" [current_project]
  set_property platform.design_intent.datacenter "false" [current_project]

    save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_gid_msg -ssname BD::TCL -id 2053 -severity "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."
