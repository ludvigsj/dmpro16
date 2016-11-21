library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity camera_starter is
PORT(
        clk       : IN     STD_LOGIC
    ;   reset     : IN     STD_LOGIC
    ;   sda       : INOUT  STD_LOGIC
    ;   scl       : INOUT  STD_LOGIC
    ;   cam_gpio  : OUT     STD_LOGIC
    ;   cam_clk   : OUT     STD_LOGIC
    ;   cam1_cp   : IN     STD_LOGIC
    ;   cam1_cn   : IN     STD_LOGIC
    
    ;   sda_out     : OUT   STD_LOGIC
    ;   scl_out     : OUT   STD_LOGIC
    ;   cam1_cp_out   : OUT     STD_LOGIC
    ;   cam1_cn_out   : OUT     STD_LOGIC
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
    
    constant NUM_MESSAGES : integer := 649;
    constant NUM_WAITS : integer := 6;
    constant NUM_CSI_MESSAGES : integer := 22;
    
    type wait_sequence_t is array (0 to NUM_WAITS-1) of std_logic_vector(31 downto 0);
    constant WAIT_SEQUENCE : wait_sequence_t := (
        x"000061A8",
        x"00198EF8",
        x"00043238",
        x"0000CB20",
        x"00036EE8",
        x"003010B0"
    );
    
    type csi_message_t is
    record
        address : byte_t;
        register_high : byte_t;
        register_low  : byte_t;
        data          : byte_t;
    end record;
    
    type csi_sequence_t is array(0 to NUM_CSI_MESSAGES-1) of csi_message_t;
    constant CSI_SEQUENCE : csi_sequence_t := (
        (x"6D", x"00", x"00", x"00"),
        (x"6C", x"01", x"03", x"01"),
        (x"6C", x"01", x"00", x"00"),
        (x"6c", x"30", x"34", x"1A"),
        (x"6c", x"30", x"35", x"21"),
        (x"6c", x"30", x"36", x"62"),
        (x"6c", x"30", x"3C", x"11"),
        (x"6c", x"31", x"06", x"F5"),
        (x"6c", x"38", x"21", x"01"),
        (x"6c", x"38", x"20", x"41"),
        (x"6c", x"38", x"27", x"EC"),
        (x"6c", x"37", x"0C", x"03"),
        (x"6c", x"36", x"12", x"59"),
        (x"6c", x"36", x"18", x"00"),
        (x"6c", x"50", x"00", x"06"),
        (x"6c", x"50", x"02", x"40"),
        (x"6c", x"50", x"03", x"08"),
        (x"6c", x"5A", x"00", x"08"),
        (x"6c", x"30", x"00", x"00"),
        (x"6c", x"30", x"01", x"00"),
        (x"6c", x"30", x"02", x"00"),
        (x"6c", x"30", x"16", x"08")
    );
    
    type i2c_sequence is array (0 to NUM_MESSAGES-1) of i2c_message_t;
    constant SEQUENCE : i2c_sequence := (
        
        
        
        
        
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
        
        (x"6C", x"38", '0'), -- TIMING_Y_ADDR_START, default 0x00
        (x"6C", x"02", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_Y_ADDR_START, default 0x04
        (x"6C", x"03", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_X_ADDR_END, default, 0x0A
        (x"6C", x"04", '0'),
        (x"6C", x"0A", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_X_ADDR_END, default 0x33
        (x"6C", x"05", '0'), 
        (x"6C", x"3F", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_Y_ADDR_END, default 0x07
        (x"6C", x"06", '0'),
        (x"6C", x"07", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_Y_ADDR_END, default 0xA3
        (x"6C", x"07", '0'),
        (x"6C", x"A3", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_X_OUTPUT_SIZE, default 0x0A
        (x"6C", x"08", '0'),
        (x"6C", x"05", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_X_OUTPUT_SIZE, default 0x20
        (x"6C", x"09", '0'),
        (x"6C", x"10", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_Y_OUTPUT_SIZE, default 0x07
        (x"6C", x"0A", '0'),
        (x"6C", x"03", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_Y_OUTPUT_SIZE, default 0x98
        (x"6C", x"0B", '0'),
        (x"6C", x"CC", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_HTS, default 0x0A
        (x"6C", x"0C", '0'),
        (x"6C", x"07", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_HTS
        (x"6C", x"0D", '0'),
        (x"6C", x"68", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_VTS
        (x"6C", x"0E", '0'),
        (x"6C", x"04", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_VTS
        (x"6C", x"0F", '0'),
        (x"6C", x"50", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_ISP_X_WIN
        (x"6C", x"11", '0'),
        (x"6C", x"10", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_ISP_Y_WIN
        (x"6C", x"13", '0'),
        (x"6C", x"06", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_X_INC
        (x"6C", x"14", '0'),
        (x"6C", x"31", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_Y_INC
        (x"6C", x"15", '0'),
        (x"6C", x"31", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"36", '0'), -- ???
        (x"6C", x"30", '0'),
        (x"6C", x"2E", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"36", '0'), -- ???
        (x"6C", x"32", '0'),
        (x"6C", x"E2", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"36", '0'), -- ???
        (x"6C", x"33", '0'),
        (x"6C", x"23", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"36", '0'), -- ???
        (x"6C", x"34", '0'),
        (x"6C", x"44", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"36", '0'), -- ???
        (x"6C", x"36", '0'),
        (x"6C", x"06", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"36", '0'), -- ???
        (x"6C", x"20", '0'),
        (x"6C", x"64", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"36", '0'), -- ???
        (x"6C", x"21", '0'),
        (x"6C", x"E0", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"36", '0'), -- ???
        (x"6C", x"00", '0'),
        (x"6C", x"37", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"37", '0'), -- ???
        (x"6C", x"04", '0'),
        (x"6C", x"A0", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"37", '0'), -- ???
        (x"6C", x"03", '0'),
        (x"6C", x"5A", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"37", '0'), -- ???
        (x"6C", x"15", '0'),
        (x"6C", x"78", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"37", '0'), -- ???
        (x"6C", x"17", '0'),
        (x"6C", x"01", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"37", '0'), -- ???
        (x"6C", x"31", '0'),
        (x"6C", x"02", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"37", '0'), -- ???
        (x"6C", x"0B", '0'),
        (x"6C", x"60", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"37", '0'), -- ???
        (x"6C", x"05", '0'),
        (x"6C", x"1A", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3F", '0'), -- ???
        (x"6C", x"05", '0'),
        (x"6C", x"02", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3F", '0'), -- ???
        (x"6C", x"06", '0'),
        (x"6C", x"10", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3F", '0'), -- ???
        (x"6C", x"01", '0'),
        (x"6C", x"0A", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- B50_STEP
        (x"6C", x"08", '0'),
        (x"6C", x"01", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- B50_STEP
        (x"6C", x"09", '0'),
        (x"6C", x"28", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- B60_STEP
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- B60_STEP
        (x"6C", x"0B", '0'),
        (x"6C", x"F6", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- B60_MAX
        (x"6C", x"0D", '0'),
        (x"6C", x"08", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- B50_MAX
        (x"6C", x"0E", '0'),
        (x"6C", x"06", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- WPT
        (x"6C", x"0F", '0'), -- stable range high limit (enter)
        (x"6C", x"58", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- BPT
        (x"6C", x"10", '0'), -- stable range low limit (enter)
        (x"6C", x"50", '0'),
        (x"FF", x"FF", '1'),
        
        
        (x"6C", x"3A", '0'), -- WPT2
        (x"6C", x"1B", '0'), -- stable range high limit (go out)
        (x"6C", x"58", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- BPT2
        (x"6C", x"1E", '0'), -- stable range low limit (go out)
        (x"6C", x"50", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- HIGH VPT
        (x"6C", x"11", '0'),
        (x"6C", x"60", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"3A", '0'), -- LOW VPT
        (x"6C", x"1F", '0'),
        (x"6C", x"28", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"40", '0'), -- BLC_CTRL01
        (x"6C", x"01", '0'),
        (x"6C", x"02", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"40", '0'), -- BLC_CTRL04
        (x"6C", x"04", '0'),
        (x"6C", x"04", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"40", '0'), -- BLC_CTRL00
        (x"6C", x"00", '0'),
        (x"6C", x"09", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"48", '0'), -- PCLK_PERIOD
        (x"6C", x"37", '0'),
        (x"6C", x"16", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"48", '0'), -- MIPI CTRL 00
        (x"6C", x"00", '0'), -- mipi bus will be LP11 when no packet to transmitt
        (x"6C", x"24", '0'), -- gate clock lane when no packet to transmit
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- MANUAL CTRL
        (x"6C", x"03", '0'), -- AGC manual and AEC manual
        (x"6C", x"03", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_TC_REG20, rpi does something weird here, maybe it matters?
        (x"6C", x"20", '0'),
        (x"6D", x"41", '1'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_TC_REG21, weird stuff here as well, maybe sequential write for 1 byte?
        (x"6C", x"21", '0'),  
        (x"6D", x"01", '1'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- same as two commands up
        (x"6C", x"20", '0'),
        (x"6C", x"41", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING_TC_REG21
        (x"6C", x"21", '0'),
        (x"6C", x"03", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- AGC
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- AGC
        (x"6C", x"0B", '0'),
        (x"6C", x"10", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"32", '0'), -- ???
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"38", '0'), -- TIMING VTS
        (x"6C", x"0E", '0'),
        (x"6C", x"05", '0'),
        (x"6C", x"9B", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- EXPOSURE
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- EXPOSURE
        (x"6C", x"01", '0'),
        (x"6C", x"1A", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- EXPOSURE
        (x"6C", x"02", '0'),
        (x"6C", x"F0", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"32", '0'), -- ???
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"32", '0'), -- ??
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- AGC
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), --  AGC
        (x"6C", x"0B", '0'),
        (x"6C", x"10", '0'),
        (x"FE", x"FF", '1'),
        
        -- Really long wait from rpi
        
        (x"6C", x"35", '0'), -- AGC
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- AGC
        (x"6C", x"0B", '0'),
        (x"6C", x"10", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"32", '0'), -- ???
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- EXPOSURE
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- EXPOSURE
        (x"6C", x"01", '0'),
        (x"6C", x"1A", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'), -- EXPOSURE
        (x"6C", x"02", '0'),
        (x"6C", x"F0", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"32", '0'), -- ????
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"32", '0'), -- ????
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"FE", x"FF", '1'),
        
        -- small pause
        
        (x"6C", x"01", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"01", '0'),
        (x"FE", x"FF", '1'),
        
        -- small pause
        
        (x"6C", x"35", '0'), -- 
        (x"6C", x"0A", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'),
        (x"6C", x"0B", '0'),
        (x"6C", x"10", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'),
        (x"6C", x"00", '0'),
        (x"6C", x"00", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'),
        (x"6C", x"01", '0'),
        (x"6C", x"1A", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"35", '0'),
        (x"6C", x"02", '0'),
        (x"6C", x"F0", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"10", '0'),
        (x"FF", x"FF", '1'),
        
        (x"6C", x"32", '0'),
        (x"6C", x"12", '0'),
        (x"6C", x"A0", '0'),
        (x"FE", x"FF", '1'),
        
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
    signal i2c_reset        : std_logic := '1';
    signal i2c_write_data   : byte_t;
    signal i2c_busy         : std_logic := '0';
    signal i2c_read_data    : byte_t;
    signal i2c_error        : std_logic := '0';
    signal i2c_reset_n      : std_logic := '1';
    signal i2c_rep_start    : std_logic := '0';
    signal busy_prev        : std_logic := '0';
    
    type state_t is (READY, PASSING_MESSAGE, I2C_TRANSMITTING, DONE, PAUSE, RESET_I2C);
    signal state : state_t := READY;
begin

    sda_out <= '0' when sda = '0' else '1';
    scl_out <= '0' when scl = '0' else '1';
    cam1_cp_out <= cam1_cp;
    cam1_cn_out <= cam1_cn;
        
    i2c : entity work.i2c_master
    generic map(
        input_clk   => 48_000_000,
        bus_clk     => 100_000
    )
    port map(
        clk         => clk,
        reset_n     => i2c_reset,
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
    
    process(clk, i2c_busy, reset) is
        variable c : integer := 0;
        variable busy_cnt : integer := 0;
    begin
        if reset = '0' then
            c := 0;
            busy_cnt := 0;
        elsif rising_edge(clk) then
            case state is
                when ready =>
                    i2c_reset <= '0';
                    state <= passing_message;
                when passing_message =>
                    i2c_reset <= '1';
                    state <= i2c_transmitting;
                when i2c_transmitting =>
                    cam_gpio <= '1';
                    cam_clk <= '1';
                    busy_prev <= i2c_busy;
                    if (busy_prev = '0' and i2c_busy = '1') then
                        busy_cnt := busy_cnt + 1;
                    end if;
                    case busy_cnt is
                        when 0 =>
                            i2c_enable <= '1';
                            i2c_addr <= CSI_SEQUENCE(c).address;
                            i2c_rw   <= CSI_SEQUENCE(c).address(0);
                            i2c_write_data <= CSI_SEQUENCE(c).register_high;
                        when 1 =>
                            i2c_enable <= '1';
                            i2c_addr <= CSI_SEQUENCE(c).address;
                            i2c_rw   <= CSI_SEQUENCE(c).address(0);
                            i2c_write_data <= CSI_SEQUENCE(c).register_low;
                        when 2 =>
                            i2c_enable <= '1';
                            i2c_addr <= CSI_SEQUENCE(c).address;
                            i2c_rw   <= CSI_SEQUENCE(c).address(0);
                            i2c_write_data <= CSI_SEQUENCE(c).data;
                        when 3 => 
                            i2c_enable <= '0';
                            if (i2c_busy = '0') then
                                if c < (NUM_CSI_MESSAGES - 1) then
                                    busy_cnt := 0;
                                    c := c + 1;
                                end if;
                            end if;
                        when others =>
                            null;
                    end case;
                when others =>
                    null;
                end case;
            end if;
    end process;
end Behavioral;