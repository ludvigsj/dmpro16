set_property -dict { PACKAGE_PIN N11    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_35 Sch=gclk[100]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

#set_property -dict { PACKAGE_PIN C12    IOSTANDARD LVCMOS33 } [get_ports { io_mosi }]; #IO_L24N_T3_35 Sch=led[4]
#set_property -dict { PACKAGE_PIN D13    IOSTANDARD LVCMOS33 } [get_ports { io_miso }]; #IO_L24N_T3_35 Sch=led[4]
#set_property -dict { PACKAGE_PIN C13    IOSTANDARD LVCMOS33 } [get_ports { io_clk }]; #IO_L24N_T3_35 Sch=led[4]
#set_property -dict { PACKAGE_PIN E12    IOSTANDARD LVCMOS33 } [get_ports { io_cs }]; #IO_L24N_T3_35 Sch=led[4]
#set_property -dict { PACKAGE_PIN A13    IOSTANDARD LVCMOS33 } [get_ports { io_wake }]; #IO_L24N_T3_35 Sch=led[4]
#set_property -dict { PACKAGE_PIN R7    IOSTANDARD LVCMOS33 } [get_ports { notreset }]; #IO_L24N_T3_35 Sch=led[4]

set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { io_mosi }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN T8    IOSTANDARD LVCMOS33 } [get_ports { io_miso }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN T7    IOSTANDARD LVCMOS33 } [get_ports { io_clk }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN R8    IOSTANDARD LVCMOS33 } [get_ports { io_cs }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN A13    IOSTANDARD LVCMOS33 } [get_ports { io_wake }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN R7    IOSTANDARD LVCMOS33 } [get_ports { notreset }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { poke }]; #IO_L24N_T3_35 Sch=led[4]

set_property -dict { PACKAGE_PIN R12    IOSTANDARD LVCMOS33 } [get_ports { rpi_poke_out }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { poke_out }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { poke_out }]; #IO_L24N_T3_35 Sch=led[4]

#set_property -dict { PACKAGE_PIN R8    IOSTANDARD LVCMOS33 } [get_ports { io_cs_out }]; #IO_L24N_T3_35 Sch=led[4]
#set_property -dict { PACKAGE_PIN T7    IOSTANDARD LVCMOS33 } [get_ports { io_clk_out }]; #IO_L24N_T3_35 Sch=led[4]
#set_property -dict { PACKAGE_PIN T8    IOSTANDARD LVCMOS33 } [get_ports { io_miso }]; #IO_L24N_T3_35 Sch=led[4]
#set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { io_mosi_out }]; #IO_L24N_T3_35 Sch=led[4]
#set_property -dict { PACKAGE_PIN T10    IOSTANDARD LVCMOS33 } [get_ports { reset_out }]; #IO_L24N_T3_35 Sch=led[4]

set_property PULLDOWN true [get_ports poke]

set_property CONFIG_VOLTAGE 3.3 [ current_design ]
set_property CFGBVS VCCO [ current_design ]