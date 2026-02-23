# set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
## Clock Signal - 100 MHz on backbone route
set_property -dict { PACKAGE_PIN R4    IOSTANDARD LVCMOS33 } [get_ports { CLK }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK]
# set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets CLK_IBUF]

## Reset button - CHANGED TO LVCMOS33 to match CLK bank
set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS33 } [get_ports { RST_N }];

## LEDs
# set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS25 } [get_ports { led0 }];
# set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS25 } [get_ports { led1 }];
# set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS25 } [get_ports { led2 }];
# set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS25 } [get_ports { led3 }];

## HDMI out
# set_property -dict { PACKAGE_PIN AA4   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_cec }]; #IO_L11N_T1_SRCC_34 Sch=hdmi_tx_cec
set_property -dict { PACKAGE_PIN U1    IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_clk_n }]; #IO_L1N_T0_34 Sch=hdmi_tx_clk_n
set_property -dict { PACKAGE_PIN T1    IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_clk_p }]; #IO_L1P_T0_34 Sch=hdmi_tx_clk_p
# set_property -dict { PACKAGE_PIN AB13  IOSTANDARD LVCMOS25 } [get_ports { hdmi_tx_hpd }]; #IO_L3N_T0_DQS_13 Sch=hdmi_tx_hpd
# set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_rscl }]; #IO_L6P_T0_34 Sch=hdmi_tx_rscl
# set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_rsda }]; #IO_L6N_T0_VREF_34 Sch=hdmi_tx_rsda
set_property -dict { PACKAGE_PIN Y1    IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_n0 }]; #IO_L5N_T0_34 Sch=hdmi_tx_n[0]
set_property -dict { PACKAGE_PIN W1    IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_p0 }]; #IO_L5P_T0_34 Sch=hdmi_tx_p[0]
set_property -dict { PACKAGE_PIN AB1   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_n1 }]; #IO_L7N_T1_34 Sch=hdmi_tx_n[1]
set_property -dict { PACKAGE_PIN AA1   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_p1 }]; #IO_L7P_T1_34 Sch=hdmi_tx_p[1]
set_property -dict { PACKAGE_PIN AB2   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_n2 }]; #IO_L8N_T1_34 Sch=hdmi_tx_n[2]
set_property -dict { PACKAGE_PIN AB3   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_p2 }]; #IO_L8P_T1_34 Sch=hdmi_tx_p[2]

## Just set IOSTANDARD, let Vivado pick pins
# set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_clk_*]
# set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_*]

## Configuration
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]