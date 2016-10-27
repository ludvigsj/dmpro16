LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_camera_starter IS
END tb_camera_starter;
 
ARCHITECTURE behavior OF tb_camera_starter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT camera_starter
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         sda : INOUT  std_logic;
         scl : INOUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

	--BiDirs
   signal sda : std_logic;
   signal scl : std_logic;

   -- Clock period definitions
   constant clk_period : time := 42 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: camera_starter PORT MAP (
          clk => clk,
          reset => reset,
          sda => sda,
          scl => scl
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for clk_period*2;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
