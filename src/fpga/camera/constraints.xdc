set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]
set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVCMOS33} [get_ports clk]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports reset]

set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS33} [get_ports sda]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports scl]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports cam_gpio]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports cam_clk]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports cam1_cp]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports cam1_cn]
set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports cam1_dp0]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS33} [get_ports cam1_dn0]




set_property -dict {PACKAGE_PIN R8 IOSTANDARD LVCMOS33} [get_ports scl_out]
set_property -dict {PACKAGE_PIN T7 IOSTANDARD LVCMOS33} [get_ports sda_out]
set_property -dict {PACKAGE_PIN T8 IOSTANDARD LVCMOS33} [get_ports cam1_cp_out]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports cam1_cn_out]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports cam1_dp0_out]
set_property -dict {PACKAGE_PIN R5 IOSTANDARD LVCMOS33} [get_ports cam1_dn0_out]

set_property PULLUP true [get_ports scl]
set_property PULLUP true [get_ports sda]
set_property PULLDOWN true [get_ports cam_gpio]
set_property PULLDOWN true [get_ports cam_clk]
