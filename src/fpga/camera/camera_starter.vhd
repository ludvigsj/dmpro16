library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

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
    ;   cam1_dn0  : IN      STD_LOGIC
    ;   cam1_dp0  : IN      STD_LOGIC
    
    ;   cam1_dn0_out    : out std_logic
    ;   cam1_dp0_out    : out std_logic
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
    
    constant NUM_MESSAGES : integer := 255;
    constant NUM_WAITS : integer := 6;
    constant NUM_CSI_MESSAGES : integer := 121;
    
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
        (x"6c", x"30", x"35", x"AA"),
        (x"6c", x"30", x"36", x"05"),
        (x"6c", x"30", x"3C", x"11"),
        (x"6c", x"31", x"06", x"F5"),
        (x"6c", x"38", x"21", x"01"),
        (x"6c", x"38", x"20", x"41"),
        (x"6c", x"38", x"27", x"EC"),
        (x"6c", x"37", x"0C", x"03"),
        (x"6c", x"36", x"12", x"59"),
        (x"6c", x"36", x"18", x"00"),
        
        (x"6c", x"50", x"3D", x"01"), -- test pattern
        
        (x"6c", x"50", x"00", x"06"),
        (x"6c", x"50", x"02", x"40"),
        (x"6c", x"50", x"03", x"08"),
        (x"6c", x"5A", x"00", x"08"),
        (x"6c", x"30", x"00", x"00"),
        (x"6c", x"30", x"01", x"00"),
        (x"6c", x"30", x"02", x"00"),
        (x"6c", x"30", x"16", x"08"),
        (x"6c", x"30", x"17", x"E0"),
        (x"6c", x"30", x"18", x"44"),
        (x"6c", x"30", x"1C", x"F8"),
        (x"6c", x"30", x"1D", x"F0"),
        (x"6c", x"3A", x"18", x"00"),
        (x"6c", x"3A", x"19", x"F8"),
        (x"6c", x"3C", x"01", x"80"),
        (x"6c", x"3B", x"07", x"0C"),
        (x"6c", x"38", x"00", x"00"),
        (x"6c", x"38", x"01", x"00"),
        (x"6c", x"38", x"02", x"00"),
        (x"6c", x"38", x"03", x"00"),
        (x"6c", x"38", x"04", x"0A"),
        (x"6c", x"38", x"05", x"3F"),
        (x"6c", x"38", x"06", x"07"),
        (x"6c", x"38", x"07", x"A3"),
        (x"6c", x"38", x"08", x"05"),
        (x"6c", x"38", x"09", x"10"),
        (x"6c", x"38", x"0A", x"03"),
        (x"6c", x"38", x"0B", x"CC"),
        (x"6c", x"38", x"0C", x"07"),
        (x"6c", x"38", x"0D", x"68"),
        (x"6c", x"38", x"0E", x"04"),
        (x"6c", x"38", x"0F", x"50"),
        (x"6c", x"38", x"11", x"10"),
        (x"6c", x"38", x"13", x"06"),
        (x"6c", x"38", x"14", x"31"),
        (x"6c", x"38", x"15", x"31"),
        (x"6c", x"36", x"30", x"2E"),
        (x"6c", x"36", x"32", x"E2"),
        (x"6c", x"36", x"33", x"23"),
        (x"6c", x"36", x"34", x"44"),
        (x"6c", x"36", x"36", x"06"),
        (x"6c", x"36", x"20", x"64"),
        (x"6c", x"36", x"21", x"E0"),
        (x"6c", x"36", x"00", x"37"),
        (x"6c", x"37", x"04", x"A0"),
        (x"6c", x"37", x"03", x"5A"),
        (x"6c", x"37", x"15", x"78"),
        (x"6c", x"37", x"17", x"01"),
        (x"6c", x"37", x"31", x"02"),
        (x"6c", x"37", x"0B", x"60"),
        (x"6c", x"37", x"05", x"1A"),
        (x"6c", x"3F", x"05", x"02"),
        (x"6c", x"3F", x"06", x"10"),
        (x"6c", x"3F", x"01", x"0A"),
        (x"6c", x"3A", x"08", x"01"),
        (x"6c", x"3A", x"09", x"28"),
        (x"6c", x"3A", x"0A", x"00"),
        (x"6c", x"3A", x"0B", x"F6"),
        (x"6c", x"3A", x"0D", x"08"),
        (x"6c", x"3A", x"0E", x"06"),
        (x"6c", x"3A", x"0F", x"58"),
        (x"6c", x"3A", x"10", x"50"),
        (x"6c", x"3A", x"1B", x"58"),
        (x"6c", x"3A", x"1E", x"50"),
        (x"6c", x"3A", x"11", x"60"),
        (x"6c", x"3A", x"1F", x"28"),
        (x"6c", x"40", x"01", x"02"),
        (x"6c", x"40", x"04", x"04"),
        (x"6c", x"40", x"00", x"09"),
        (x"6c", x"48", x"37", x"16"),
        (x"6c", x"48", x"00", x"24"),
        (x"6c", x"35", x"03", x"03"),
        (x"6c", x"48", x"20", x"41"),
        (x"6c", x"38", x"21", x"01"),
        (x"6c", x"38", x"20", x"41"),
        (x"6c", x"38", x"21", x"03"),
        (x"6c", x"35", x"0A", x"00"),
        (x"6c", x"35", x"0B", x"10"),
        (x"6c", x"32", x"12", x"00"),
        (x"6c", x"38", x"0E", x"05"), -- ?? should be 2 data bits /o\
        
               
     --    (x"6C", x"38", '0'), -- TIMING VTS
     --    (x"6C", x"0E", '0'),
     --    (x"6C", x"05", '0'),
     --    (x"6C", x"9B", '0'),
     --    (x"FF", x"FF", '1'),
     
     
        (x"6c", x"35", x"00", x"00"),
        (x"6c", x"35", x"01", x"1A"),
        (x"6c", x"35", x"02", x"F0"),
        (x"6c", x"32", x"12", x"A0"),
        (x"6c", x"35", x"0A", x"00"),
        (x"6c", x"35", x"0B", x"10"),
        (x"6c", x"35", x"0A", x"00"),
        (x"6c", x"35", x"0B", x"10"),
        (x"6c", x"32", x"12", x"00"),
        (x"6c", x"35", x"00", x"00"),
        (x"6c", x"35", x"01", x"1A"),
        (x"6c", x"35", x"02", x"F0"),
        (x"6c", x"32", x"12", x"10"),
        (x"6c", x"32", x"12", x"A0"),
        (x"6c", x"01", x"00", x"01"),
        (x"6c", x"35", x"0A", x"FF"),
        (x"6c", x"35", x"0B", x"10"),
        (x"6c", x"32", x"12", x"00"),
        (x"6c", x"35", x"00", x"00"),
        (x"6c", x"35", x"01", x"1A"),
        (x"6c", x"35", x"02", x"F0"),
        (x"6c", x"32", x"12", x"10"),
        (x"6c", x"32", x"12", x"A0"),
        (x"6c", x"35", x"0A", x"00"),
        (x"6c", x"35", x"0B", x"0B"),
        (x"6c", x"32", x"12", x"00")
    );
    
    type i2c_sequence is array (0 to NUM_MESSAGES-1) of i2c_message_t;
    constant SEQUENCE : i2c_sequence := (
        
        
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
    signal pclk             : std_logic;
    
    type state_t is (READY, PASSING_MESSAGE, I2C_TRANSMITTING, DONE, PAUSE, RESET_I2C);
    signal state : state_t := READY;
begin

    sda_out <= '0' when sda = '0' else '1';
    scl_out <= '0' when scl = '0' else '1';
    cam1_cp_out <= cam1_cp;
    cam1_cn_out <= cam1_cn;
    cam1_dp0_out <= cam1_dp0;
    cam1_dn0_out <= cam1_dn0;
        
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
    
    --IBUFDS_inst : IBUFDS
    --generic map (
      --  diff_term => true,
     --   ibuf_low_pwr => true,
     --   iostandard => "default"
    --)
    --port map (
    --    O => pclk,
    --    I => cam1_cp,
    --    IB => cam1_cn
    --);
    
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