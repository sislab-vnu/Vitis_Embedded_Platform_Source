# Pin source: Huins MFP-VP1902-S User's Guide, Table 24, pages 46-47.
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
