----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2016 01:54:32 PM
-- Design Name: 
-- Module Name: csi2_master - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity csi2_master is
    Generic (   input_clk   : INTEGER := 50_000_000;
                bus_clk     : INTEGER := 400_000);
    Port (      clk         : in    STD_LOGIC;
                reset       : in    STD_LOGIC;
                ena         : in    STD_LOGIC;
                rw          : in    STD_LOGIC;
                busy        : out   STD_LOGIC;
                transmitting: out   STD_LOGIC;
                data_wr     : in    STD_LOGIC_VECTOR(7 downto 0);
                data_rd     : out   STD_LOGIC_VECTOR(7 downto 0);
                sda         : inout STD_LOGIC;
                scl         : inout STD_LOGIC);
end csi2_master;

architecture Behavioral of csi2_master is
    constant cycles : integer := (input_clk / bus_clk) / 4;
    type machine is (ready, start, slave_ack, wr, rd, master_ack, stop);
    signal state            : machine;
    signal data_clk         : STD_LOGIC;
    signal data_clk_prev    : STD_LOGIC;
    signal scl_clk          : STD_LOGIC;
    signal scl_ena          : STD_LOGIC;
    signal sda_internal     : STD_LOGIC;
    signal sda_ena          : STD_LOGIC;
    signal data_tx          : STD_LOGIC_VECTOR(7 downto 0);
    signal data_rx          : STD_LOGIC_VECTOR(7 downto 0);
    signal bit_count        : INTEGER RANGE 0 TO 7 := 7;
begin
    clock_timing : process(clk, reset)
        variable count : integer range 0 to cycles*4;
    begin
        if (reset = '1') then
            count := 0;
        elsif rising_edge(clk) then
            data_clk_prev <= data_clk;
            if (count = cycles*4 -1) then
                count := 0;
            else
                count := count + 1;
            end if;
            
            case count is
                when 0 to cycles-1 =>
                    scl_clk <= '0';
                    data_clk <= '0';
                when cycles to cycles*2 - 1 =>
                    scl_clk <= '0';
                    data_clk <= '1';
                when cycles*2 to cycles*3 - 1 =>
                    scl_clk <= '1';
                    data_clk <= '1';
                when others =>
                    scl_clk <= '1';
                    data_clk <= '0';
            end case;
        end if;
    end process;
    
    state_machine : process(clk, reset)
    begin
        if (reset = '1') then
            state <= ready;
            scl_ena <= '0';
            busy <= '1';
            sda_internal <= '1';
            bit_count <= 7;
            data_rd <= "00000000";
        elsif rising_edge(clk) then
            if (data_clk = '1' and data_clk_prev = '0') then
                case state is
                    when ready =>
                        if (ena = '1') then
                            busy <= '1';
                            data_tx <= data_wr;
                            state <= start;
                        else
                            state <= ready;
                            busy <= '0';
                        end if;
                    when start =>
                        busy <= '1';
                        if rw = '0' then
                            sda_internal <= data_tx(bit_count);
                            state <= wr;
                        else
                            sda_internal <= '1';
                            state <= rd;
                        end if;
                    when wr =>
                        transmitting <= '1';
                        if (bit_count = 0) then
                            sda_internal <= '1';
                            bit_count <= 7;
                            state <= slave_ack;
                        else
                            bit_count <= bit_count - 1;
                            sda_internal <= data_tx(bit_count-1);
                            state <= wr;
                        end if;
                    when rd =>
                        transmitting <= '1';
                        if (bit_count = 0) then
                            bit_count <= 7;
                            data_rd <= data_rx;
                            state <= master_ack;
                        else
                            bit_count <= bit_count -1;
                            state <= rd;
                        end if;
                    when slave_ack =>
                        transmitting <= '0';
                        if (ena = '1') then
                            busy <= '0';
                            data_tx <= data_wr;
                            if (data_wr = x"FF") then
                                state <= stop;
                            elsif (rw = '0') then
                                state <= wr;
                                sda_internal <= data_wr(bit_count);
                            else
                                state <= start;
                            end if;
                        else
                            state <= stop;
                        end if;
                    when master_ack =>
                        transmitting <= '0';
                        if (ena = '1') then
                            busy <= '0';
                            data_tx <= data_wr;
                            if (data_wr = x"FF") then
                                state <= stop;
                            elsif (rw = '0') then
                                sda_internal <= '1';
                                state <= rd;
                            else
                                state <= start;
                            end if;
                        else
                            state <= stop;
                        end if;
                    when stop =>
                        busy <= '0';
                        state <= ready;
                end case;
            end if;
        elsif data_clk = '0' and data_clk_prev = '1' then
            case state is
                when start =>
                    if (scl_ena = '0') then
                        scl_ena <= '1';
                    end if;
                when slave_ack =>
                    if (sda /= '0') then
                        busy <= '0';
                        state <= ready;
                    end if;
                when stop =>
                    scl_ena <= '0';
                when others =>
                    null;
            end case;  
        end if;
    end process;
    
    with state select
        sda_ena <= data_clk_prev when start,
                   not data_clk_prev when stop,
                   sda_internal when others;
    scl <= '0' when (scl_ena = '1' and scl_clk = '0') else 'Z';
    sda <= '0' when sda_ena = '0' else 'Z';
end Behavioral;
