library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity camera_tb is
end camera_tb;

architecture Behavioral of camera_tb is
    component camera
    port (
        clk     : in    STD_LOGIC;
        reset   : in    STD_LOGIC;
        sda     : inout STD_LOGIC;
        scl     : inout STD_LOGIC
        );
    end component;
    
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    
    signal sda : std_logic;
    signal scl : std_logic;
    
    constant clk_period : time := 42 ns;
    
begin

    uut: camera PORT MAP (
        clk => clk,
        reset => reset,
        sda => sda,
        scl => scl
    );
    
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc : process
    begin
        reset <= '1';
        wait for clk_period*2;
        reset <= '0';
        wait;
    end process;

end Behavioral;
