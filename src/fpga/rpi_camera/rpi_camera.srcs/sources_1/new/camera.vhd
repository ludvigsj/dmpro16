----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2016 03:17:27 PM
-- Design Name: 
-- Module Name: camera - Behavioral
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

entity camera is
    Port ( clk      : in    STD_LOGIC;
           reset    : in    STD_LOGIC;
           sda      : inout STD_LOGIC;
           scl      : inout STD_LOGIC);
end camera;

architecture Behavioral of camera is
    type machine is (ready, passing_message, transmission_start, transmitting, done, pause);
    signal state : machine := ready;
    signal csi_ena      : STD_LOGIC;
    signal csi_rw       : STD_LOGIC;
    signal csi_busy     : STD_LOGIC;
    signal csi_transmitting   : STD_LOGIC;
    signal csi_data_wr  : STD_LOGIC_VECTOR(7 downto 0);
    signal csi_data_rd  : STD_LOGIC_VECTOR(7 downto 0);
    
    
    type csi_byte is
    record
        data    : STD_LOGIC_VECTOR(7 downto 0);
        rw      : STD_LOGIC;
        stop    : STD_LOGIC;
    end record;
    
    constant NUM_MESSAGES : integer := 32;
    type csi_sequence_t is array (0 to NUM_MESSAGES-1) of csi_byte;
    constant csi_sequence : csi_sequence_t := (
        (x"6C", '0', '0'),
        (x"6D", '1', '0'),
        (x"FF", '0', '1'),
        (x"6C", '0', '0'),
        (x"6D", '1', '0'),
        (x"FF", '0', '1'),
        (x"6C", '0', '0'),
        (x"6D", '1', '0'),
        (x"FF", '0', '1'),
        (x"FE", '0', '1'),
        
        (x"6C", '0', '0'),
        (x"6D", '1', '0'),
        (x"FF", '0', '1'),
        (x"6C", '0', '0'),
        (x"6D", '1', '0'),
        (x"FF", '0', '1'),
        (x"6C", '0', '0'),
        (x"6D", '1', '0'),
        (x"FF", '0', '1'),
        (x"FE", '0', '1'),
        
        (x"6C", '0', '0'),
        (x"6D", '1', '0'),
        (x"FF", '0', '1'),
        (x"6C", '0', '0'),
        (x"6D", '1', '0'),
        (x"FF", '0', '1'),
        (x"6C", '0', '0'),
        (x"30", '0', '0'),
        (x"0A", '0', '0'),
        (x"6D", '1', '0'),
        (x"00", '1', '1'),
        (x"00", '1', '1')
    );

begin
    i2c : entity work.csi2_master
    generic map(
        input_clk       => 24_000_000,
        bus_clk         => 100_000
    )
    port map(
        clk             => clk,
        reset           => reset,
        ena             => csi_ena,
        rw              => csi_rw,
        busy            => csi_busy,
        transmitting    => csi_transmitting,
        data_wr         => csi_data_wr,
        data_rd         => csi_data_rd,
        sda             => sda,
        scl             => scl
    );
    
    take_picture : process(reset, clk, csi_busy) is
        variable c  : integer := 0;
        variable d  : integer := 0;
    begin
        if reset = '1' then
            state <= ready;
            c := 0;
        elsif rising_edge(clk) then
            case state is
                when ready =>
                    if (csi_sequence(c).data = x"FF") then
                        state <= ready;
                        csi_ena <= '0';
                        c := c + 1;
                    elsif (csi_sequence(c).data = x"FE") then
                        state <= pause;
                        csi_ena <= '0';
                        c := c + 1;
                    else
                        csi_data_wr <= csi_sequence(c).data;
                        csi_rw <= csi_sequence(c).rw;
                        csi_ena <= '1';
                        state <= passing_message;
                    end if;
                when passing_message =>
                    if csi_busy = '1' then
                        c := c + 1;
                        state <= transmission_start;
                    end if;
                when transmission_start =>
                    if csi_transmitting = '1' then
                        state <= transmitting;
                    end if;
                when transmitting =>
                    if csi_busy = '0' then
                        if c >= NUM_MESSAGES then
                            state <= done;
                        else
                            state <= ready;
                        end if;
                    elsif c < NUM_MESSAGES then
                        csi_data_wr <= csi_sequence(c).data;
                    end if;
                when pause =>
                    d := d + 1;
                    if (d = 23810) then
                        d := 0;
                        state <= ready;
                    end if;
                when done =>
                    csi_ena <= '0';
            end case;
        end if;
    end process;
        


end Behavioral;