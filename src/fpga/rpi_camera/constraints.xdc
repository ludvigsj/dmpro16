set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]
set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVCMOS33} [get_ports clk]

set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports rpi_clk]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports data_out]
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports data_in]
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports rpi_start]

set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports trans_write]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports trans_data]
set_property -dict {PACKAGE_PIN R7 IOSTANDARD LVCMOS33} [get_ports trans_full]

set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports start]
set_property -dict {PACKAGE_PIN P10 IOSTANDARD LVCMOS33} [get_ports read_data_ena]

set_property PULLDOWN true [get_ports start]