
## Clock Signal - 100 MHz
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports CLK]

## Reset button
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS15} [get_ports RST_N]

## HDMI TX Clock
set_property -dict {PACKAGE_PIN T1 IOSTANDARD TMDS_33} [get_ports hdmi_tx_clk_p]
set_property -dict {PACKAGE_PIN U1 IOSTANDARD TMDS_33} [get_ports hdmi_tx_clk_n]

## HDMI TX Data 0 (Red)
set_property -dict {PACKAGE_PIN W1 IOSTANDARD TMDS_33} [get_ports hdmi_tx_p0]
set_property -dict {PACKAGE_PIN Y1 IOSTANDARD TMDS_33} [get_ports hdmi_tx_n0]

## HDMI TX Data 1 (Green)
set_property -dict {PACKAGE_PIN AA1 IOSTANDARD TMDS_33} [get_ports hdmi_tx_p1]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD TMDS_33} [get_ports hdmi_tx_n1]

## HDMI TX Data 2 (Blue)
set_property -dict {PACKAGE_PIN AB3 IOSTANDARD TMDS_33} [get_ports hdmi_tx_p2]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD TMDS_33} [get_ports hdmi_tx_n2]

## SPI Configuration
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

## Configuration
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]


