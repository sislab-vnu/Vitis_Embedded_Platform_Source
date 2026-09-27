# Pin source: Huins MFP-VP1902-S User's Guide, Table 24, pages 46-47.

# Clock Module CLK0 PL reference output; XPIO bank 706 is 1.5 V by default.
set_property -dict {PACKAGE_PIN CR58 IOSTANDARD LVDS15} [get_ports CLK0_100M_clk_p]
set_property -dict {PACKAGE_PIN CR57 IOSTANDARD LVDS15} [get_ports CLK0_100M_clk_n]

# These XIO peripheral signals are all in 1.8 V HDIO bank 408.
set_property -dict {PACKAGE_PIN BM13 IOSTANDARD LVCMOS18} [get_ports GEM1_MDIO_mdc]
set_property -dict {PACKAGE_PIN BL13 IOSTANDARD LVCMOS18} [get_ports GEM1_MDIO_mdio_io]

set_property -dict {PACKAGE_PIN BM17 IOSTANDARD LVCMOS18} [get_ports I2C0_scl_io]
set_property -dict {PACKAGE_PIN BM18 IOSTANDARD LVCMOS18} [get_ports I2C0_sda_io]
set_property -dict {PACKAGE_PIN BL16 IOSTANDARD LVCMOS18} [get_ports I2C1_scl_io]
set_property -dict {PACKAGE_PIN BM16 IOSTANDARD LVCMOS18} [get_ports I2C1_sda_io]

# Keep the board's native UART numbering: CP210 is UART1 on BK13/BL14.
set_property -dict {PACKAGE_PIN BK17 IOSTANDARD LVCMOS18} [get_ports UART0_rxd]
set_property -dict {PACKAGE_PIN BL18 IOSTANDARD LVCMOS18} [get_ports UART0_txd]
set_property -dict {PACKAGE_PIN BK13 IOSTANDARD LVCMOS18} [get_ports UART1_rxd]
set_property -dict {PACKAGE_PIN BL14 IOSTANDARD LVCMOS18} [get_ports UART1_txd]
