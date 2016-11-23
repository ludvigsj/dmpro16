library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity camera_starter is
PORT(
        clk             : IN    STD_LOGIC
    ;   start           : IN    STD_LOGIC
    ;   rpi_start       : OUT   STD_LOGIC
    ;   rpi_clk         : OUT   STD_LOGIC
    ;   data_out        : OUT   STD_LOGIC
    ;   data_in         : IN    STD_LOGIC
    ;   read_data_ena   : IN    STD_LOGIC
    ;   trans_write     : OUT   STD_LOGIC
    ;   trans_data      : OUT   STD_LOGIC
    ;   trans_full      : OUT   STD_LOGIC
    );
end camera_starter;

architecture Behavioral of camera_starter is
    
    signal rpi_clk_internal : STD_LOGIC;
begin
    
    rpi_clk <= rpi_clk_internal;
    
    rpi_start <= start;
    

    clock_gen : process (clk)
        variable counter : integer := 0;
    begin
        if rising_edge(clk) and read_data_ena = '1' then
            counter := counter + 1;
            case counter is
                when 48 =>
                    rpi_clk_internal <= '0';
                when 96 =>
                    rpi_clk_internal <= '1';
                    counter := 0;
                when others =>
                    null;
            end case;
        end if;
    end process;
    
    trans_write <= read_data_ena;
    
    data_read : process (rpi_clk_internal)
    begin
        if falling_edge(rpi_clk_internal) then
            if read_data_ena = '1' then
                if data_in = '1' then
                    data_out <= '1';
                    trans_data <= '1';
                else
                    data_out <= '0';
                    trans_data <= '0';
                end if;
            else
                
            end if;
        end if;
        
    end process;
    
end Behavioral;