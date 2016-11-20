library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity camera_starter is
PORT(
        clk       : IN     STD_LOGIC
    ;   reset     : IN     STD_LOGIC
    ;   sda       : INOUT  STD_LOGIC
    ;   scl       : INOUT  STD_LOGIC
    ;   cam_gpio      : OUT     STD_LOGIC
    ;   cam_clk   : OUT     STD_LOGIC
    ;   cam1_cp  : IN     STD_LOGIC
    ;   cam1_cn   : IN     STD_LOGIC
    ;   cam1_dp1  : IN      STD_LOGIC
    ;   cam1_dn1  : IN      STD_LOGIC
    ;   cam1_dp0  : in      STD_LOGIC
    ;   cam1_dn0  : in      STD_LOGIC
    
    ;   sda_out     : OUT   STD_LOGIC
    ;   scl_out     : OUT   STD_LOGIC
    ;   cam1_cp_out   : OUT     STD_LOGIC
    ;   cam1_cn_out   : OUT     STD_LOGIC
    ;   cam1_dp1_out  : OUT     STD_LOGIC
    ;   cam1_dn1_out  : OUT STD_LOGIC
    );
end camera_starter;

architecture Behavioral of camera_starter is
    subtype byte_t is std_logic_vector(7 downto 0);
    type i2c_message_t is
    record
        address : byte_t;
        data    : byte_t;
        rw      : std_logic; -- '1' is read
    end record;
    
    constant NUM_MESSAGES : integer := 653;
    type i2c_sequence is array (0 to NUM_MESSAGES-1) of i2c_message_t;
    constant SEQUENCE : i2c_sequence := (
        
        (x"6D", x"00", '1'), -- Doens't do anything, but things fail if it is not there
        
        (x"6C", x"30", '0'), -- Read SC_CMMN_CHIP_ID
        (x"6C", x"0A", '0'), -- Which for the Rpi 1 camera
        (x"6D", x"56", '1'), -- should be 0x5647
        (x"6D", x"47", '1'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"01", '0'), -- Software reset,
        (x"6C", x"03", '0'), -- by setting 0x0103 to high
        (x"6C", x"01", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"01", '0'), -- Sleep
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"01", '0'), -- More sleep?
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"01", '0'), -- Software reset again
        (x"6C", x"03", '0'),
        (x"6C", x"01", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- SC_CMMN_PLL_CTRL0, 0x1A is defualt...
        (x"6C", x"34", '0'), -- sets mipi bit mode to 8 bits, and some pll_charge_pump ??
        (x"6C", x"1A", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- SC_CMMN_PLL_CTRL1, 0x11 is default
        (x"6C", x"35", '0'), -- sets system_clock_div to 0b0010
        (x"6C", x"21", '0'), -- and scale_divider_mipi to 0b0001
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- SC_CMMN_PLL_MULTIPLIER, 0x69 is default
        (x"6C", x"36", '0'), -- sets it to 98
        (x"6C", x"62", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- SC_CMMN_PLLS_CTRL2, default is 0x11
        (x"6C", x"3C", '0'), -- sets plls_cp to 0b0001
        (x"6C", x"11", '0'), -- and plls_sys_div to 0b0001
        (x"FF", x"FF", '1'),
        
        (x"6C", x"31", '0'), -- SRB CTRL, default is 0xF9
        (x"6C", x"06", '0'), -- enables SCLK to arbiter, does not reset arbiter
        (x"6C", x"F5", '0'), -- sets pll_sclk/2
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMINMG_TC_REG_21, default is 0x00
        (x"6C", x"21", '0'), -- sets r_hbin
        (x"6C", x"01", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_TC_REG_20, default is 0x40
        (x"6C", x"20", '0'), -- sets r_vbin
        (x"6C", x"41", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- ???? Can't find this register
        (x"6C", x"27", '0'),
        (x"6C", x"EC", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"37", '0'), -- ??? Nope
        (x"6C", x"0C", '0'),
        (x"6C", x"03", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"36", '0'), --- Nope
        (x"6C", x"12", '0'),
        (x"6C", x"59", '0'),                    
        (x"FF", x"FF", '1'),
        
        (x"6C", x"36", '0'), -- Nope
        (x"6C", x"18", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"50", '0'), -- ISP_CTRL00, default is 0xFF
        (x"6C", x"00", '0'), -- disables lenc_en
        (x"6C", x"06", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"50", '0'), -- ISP_CTRL02, default is 0x41
        (x"6C", x"02", '0'), -- disable awb_gain_en
        (x"6C", x"40", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"50", '0'), -- ISP_CTRL03, default is 0x0A
        (x"6C", x"03", '0'), -- bin_auto_en is disabled
        (x"6C", x"08", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"5A", '0'), -- DIGC_CTRL0, default is 0x00
        (x"6C", x"00", '0'), -- 0x08 = 0b1000, bit 4 is supposedly not in use...
        (x"6C", x"08", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- SC_CMMN_PAD_OEN0, default 0x00
        (x"6C", x"00", '0'), -- 
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- SC_CMMN_PAD_OEN1, default 0x00
        (x"6C", x"01", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- SC_CMMN_PAD_OEN2, default 0x00
        (x"6C", x"02", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- SC_CMMN_MIPI_PHY, default 0x00
        (x"6C", x"16", '0'), -- sets mipi_pad_enable high
        (x"6C", x"08", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- SC_CMMN_MIPI_PHY, default 0x10
        (x"6C", x"17", '0'), -- pgm_vcm = 0b11
        (x"6C", x"E0", '0'), -- pgm_lptx = 0b10
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- SC_CMMN_MIPI_SC_CTRL0, default 0x58
        (x"6C", x"18", '0'), -- MIPI enable set to high
        (x"6C", x"44", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- ???
        (x"6C", x"1C", '0'),
        (x"6C", x"F8", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"30", '0'), -- ???
        (x"6C", x"1D", '0'),
        (x"6C", x"F0", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- AEC GAIN CEILING, default 0x00
        (x"6C", x"18", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- AEC GAIN CEILING, default 0x7C
        (x"6C", x"19", '0'), -- ???
        (x"6C", x"F8", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3C", '0'), -- 50/60 HZ DETECTION CTRL01, default 0x00
        (x"6C", x"01", '0'), -- manual mode enabled
        (x"6C", x"80", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3B", '0'), -- TIMING_Y_ADDR_END, default 0xA3
        (x"6C", x"07", '0'),
        (x"6C", x"0C", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_X_ADDR_START, defailt 0x00
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_X_ADDR_START, default 0x0C
        (x"6C", x"01", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"03", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"04", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"05", '0'),
        (x"6C", x"3F", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"06", '0'),
        (x"6C", x"07", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"07", '0'),
        (x"6C", x"A3", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"08", '0'),
        (x"6C", x"05", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"09", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"03", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"CC", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"0C", '0'),
        (x"6C", x"07", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"0D", '0'),
        (x"6C", x"68", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"0E", '0'),
        (x"6C", x"04", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"0F", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"11", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"13", '0'),
        (x"6C", x"06", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"14", '0'),
        (x"6C", x"31", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"15", '0'),
        (x"6C", x"31", '0'),
        (x"6C", x"36", '0'),
        (x"6C", x"30", '0'),
        (x"6C", x"2E", '0'),
        (x"6C", x"36", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"E2", '0'),
        (x"6C", x"36", '0'),
        (x"6C", x"33", '0'),
        (x"6C", x"23", '0'),
        (x"6C", x"36", '0'),
        (x"6C", x"34", '0'),
        (x"6C", x"44", '0'),
        (x"6C", x"36", '0'),
        (x"6C", x"36", '0'),
        (x"6C", x"06", '0'),
        (x"6C", x"36", '0'),
        (x"6C", x"20", '0'),
        (x"6C", x"64", '0'),
        (x"6C", x"36", '0'),
        (x"6C", x"21", '0'),
        (x"6C", x"E0", '0'),
        (x"6C", x"36", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"37", '0'),
        (x"6C", x"37", '0'),
        (x"6C", x"04", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"37", '0'),
        (x"6C", x"03", '0'),
        (x"6C", x"5A", '0'),
        (x"6C", x"37", '0'),
        (x"6C", x"15", '0'),
        (x"6C", x"78", '0'),
        (x"6C", x"37", '0'),
        (x"6C", x"17", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"37", '0'),
        (x"6C", x"31", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"37", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"60", '0'),
        (x"6C", x"37", '0'),
        (x"6C", x"05", '0'),
        (x"6C", x"1A", '0'),
        (x"6C", x"3F", '0'),
        (x"6C", x"05", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"3F", '0'),
        (x"6C", x"06", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"3F", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"08", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"09", '0'),
        (x"6C", x"28", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"F6", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"0D", '0'),
        (x"6C", x"08", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"0E", '0'),
        (x"6C", x"06", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"0F", '0'),
        (x"6C", x"58", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"1B", '0'),
        (x"6C", x"58", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"1E", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"11", '0'),
        (x"6C", x"60", '0'),
        (x"6C", x"3A", '0'),
        (x"6C", x"1F", '0'),
        (x"6C", x"28", '0'),
        (x"6C", x"40", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"40", '0'),
        (x"6C", x"04", '0'),
        (x"6C", x"04", '0'),
        (x"6C", x"40", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"09", '0'),
        (x"6C", x"48", '0'),
        (x"6C", x"37", '0'),
        (x"6C", x"16", '0'),
        (x"6C", x"48", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"24", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"03", '0'),
        (x"6C", x"03", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"20", '0'),
        (x"6D", x"41", '1'),
        (x"6C", x"38", '0'),
        (x"6C", x"21", '0'),
        (x"6D", x"01", '1'),
        (x"6C", x"38", '0'),
        (x"6C", x"20", '0'),
        (x"6C", x"41", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"21", '0'),
        (x"6C", x"03", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"38", '0'),
        (x"6C", x"0E", '0'),
        (x"6C", x"05", '0'),
        (x"6C", x"9B", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"1A", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"F0", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"1A", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"F0", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"1A", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"F0", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"13", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"58", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"D0", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"13", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"58", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"D0", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"1C", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"59", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"23", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"59", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"25", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"59", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"26", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"59", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"26", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"59", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"26", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"59", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"26", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"59", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"26", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"59", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"27", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"59", '0'),
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"50", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0')
    );
    signal i2c_enable       : std_logic := '0';
    signal i2c_addr         : byte_t;
    signal i2c_rw           : std_logic;
    signal i2c_write_data   : byte_t;
    signal i2c_busy         : std_logic := '0';
    signal i2c_read_data    : byte_t;
    signal i2c_error        : std_logic := '0';
    signal i2c_reset_n      : std_logic := '1';
    signal i2c_rep_start    : std_logic := '0';
begin

    sda_out <= '0' when sda = '0' else '1';
    scl_out <= '0' when scl = '0' else '1';
    cam1_cp_out <= cam1_cp;
    cam1_dn1_out <= cam1_dn1;
    cam1_dp1_out <= cam1_dp1;
        cam1_cn_out <= cam1_cn;
    i2c : entity work.i2c_master
    generic map(
        input_clk   => 48_000_000,
        bus_clk     => 100_000
    )
    port map(
        clk         => clk,
        reset_n     => reset,
        ena         => i2c_enable,
        addr        => i2c_addr(7 downto 1),
        rw          => i2c_rw,
        data_wr     => i2c_write_data,
        busy        => i2c_busy,
        rep_start   => i2c_rep_start,
        data_rd     => i2c_read_data,
        ack_error   => i2c_error,
        sda         => sda,
        scl         => scl
    );
    
    feed_messages: process(reset, clk, i2c_busy) is
        variable c    : integer := 0;
        type state_t is (READY, PASSING_MESSAGE, I2C_TRANSMITTING, DONE);
        variable state : state_t := READY;
    begin
        if reset = '0' then
            c := 0;
            state := READY;
        elsif rising_edge(clk) then
            case STATE is
            when READY =>
                i2c_rep_start <= '0';
                cam_gpio <= '1';
                cam_clk <= '1';
                i2c_addr <= SEQUENCE(c).address;
                i2c_write_data <= SEQUENCE(c).data;
                i2c_rw <= SEQUENCE(c).rw;
                i2c_enable <= '1';
                state := PASSING_MESSAGE;
            when PASSING_MESSAGE =>
                if i2c_busy = '1' then
                    c := (c + 1);
                    state := I2C_TRANSMITTING;
                end if;
            when I2C_TRANSMITTING =>
                if (SEQUENCE(c).address = x"FF") then
                    i2c_rep_start <= '1';
                    c := (c + 1);
                end if;
                if i2c_busy = '0' then
                    if c >= NUM_MESSAGES then
                        state := DONE;
                    else
                        state := READY;
                    end if;
                end if;
            when DONE =>
                cam_gpio <= '0';
                cam_clk <= '0';
                i2c_enable <= '0';
            when others =>
                --
            end case;
        end if;
    end process feed_messages;
end Behavioral;

