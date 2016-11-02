set_property -dict { PACKAGE_PIN E3		IOSTANDARD LVCMOS33		} [get_ports { CLK100MHZ }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { CLK100MHZ }];

set_property -dict { PACKAGE_PIN C12	IOSTANDARD LVCMOS33		} [get_ports { io_mosi }]; #PE10
set_property -dict { PACKAGE_PIN D13	IOSTANDARD LVCMOS33		} [get_ports { io_miso }]; #PE11
set_property -dict { PACKAGE_PIN C13	IOSTANDARD LVCMOS33		} [get_ports { io_clk }]; #PE12
set_property -dict { PACKAGE_PIN E12	IOSTANDARD LVCMOS33		} [get_ports { io_cs }]; #PE13
