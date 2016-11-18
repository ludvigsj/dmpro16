library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_FIFO;

entity sudo_ku is
    port (rst                : in std_logic;
          fpgaclock          : in std_logic;
          camerabus_sda0     : inout std_logic;
          camerabus_scl0     : inout std_logic;
          camerabus_cam_clk  : out std_logic;
          camerabus_cam_gpio : in std_logic; -- TODO: Sjekk at retning stemmer
          camerabus_cam1_cp  : in std_logic;
          camerabus_cam1_cn  : in std_logic;
          camerabus_cam1_dp1 : in std_logic;
          camerabus_cam1_dn1 : in std_logic;
          camerabus_cam1_dp0 : in std_logic;
          camerabus_cam1_dn0 : in std_logic;
          fpgabus_0          : in std_logic; -- Poke in
          fpgabus_1          : out std_logic; -- Poke out

            -- SPI:
          fpgabus_12         : in std_logic; -- SPI sclk
          fpgabus_13         : in std_logic; -- SPI SS
          fpgabus_10         : in std_logic; -- SPI MOSI
          fpgabus_11         : out std_logic -- SPI MISO
      );
    -- TODO: Add SPI-bus + enable to ports
end entity sudo_ku;

architecture behavior of sudo_ku is
    
    -- No CameraController-component, because it's already a VHDL entity and
    -- can be directly instantiated

    component Transformer is
        port(
            clk          : in std_logic;
            reset        : in std_logic;
            io_cam_read  : out std_logic;
            io_cam_data  : in std_logic_vector(0 downto 0);
            io_cam_empty : in std_logic;
            io_bnn_write : out std_logic;
            io_bnn_data  : out std_logic_vector(0 downto 0);
            io_bnn_full  : in std_logic
        );
    end component;

    component BNN is
        port(
            clk            : in std_logic;
            reset          : in std_logic;
            io_trans_read  : out std_logic;
            io_trans_data  : in std_logic_vector(0 downto 0);
            io_trans_empty : in std_logic;
            io_spi_write   : out std_logic;
            io_spi_data    : out std_logic_vector(9 downto 0);
            io_spi_full    : in std_logic
        );
    end component;

    component SpiSlave is
        port(
            clk          : in std_logic;
            reset        : in std_logic;
            io_bnn_read  : out std_logic;
            io_bnn_data  : in std_logic_vector(9 downto 0);
            io_bnn_empty : in std_logic;
            io_sclk      : in std_logic;
            io_mosi      : in std_logic;
            io_miso      : out std_logic;
            io_ss        : in std_logic
        );
    end component;

    signal iCamTransW, iCamTransF,
        oCamTransR, oCamTransE, 
        iTransBnnW, iTransBnnF,
        oTransBnnR, oTransBnnE,
        iBnnSpiW, iBnnSpiF,
        oBnnSpiR, oBnnSpiE : std_logic;
    signal iCamTransD, oCamTransD, iTransBnnD,
        oTransBnnD : std_logic_vector(0 downto 0);
    signal iBnnSpiD, oBnnSpiD : std_logic_vector(9 downto 0);
begin
    cam: entity work.cameraController
        port map(clk => fpgaclock, rst => rst, enable => enable,
            trans_write => iCamTransW, trans_data => iCamTransD,
            trans_full => iCamTransF);
        -- TODO: add CSI ports
    trans: Transformer
        port map(clk => fpgaclock, reset => rst,
            io_cam_read => oCamTransR, io_cam_data => oCamTransD,
            io_cam_empty => oCamTransE,
            io_bnn_write => iTransBnnW, io_bnn_data => iTransBnnD,
            io_bnn_full => iTransBnnF);
    bnn_inst: BNN
        port map(clk => fpgaclock, reset => rst,
            io_trans_read => oTransBnnR, io_trans_data => oTransBnnD,
            io_trans_empty => oTransBnnE,
            io_spi_write => iBnnSpiW, io_spi_data => iBnnSpiD,
            io_spi_full => iBnnSpiF);
    spi: SpiSlave
        port map(clk => fpgaclock, reset => rst,
            io_bnn_read => oBnnSpiR, io_bnn_data => oBnnSpiD,
            io_bnn_empty => oBnnSpiE,
            io_sclk => fpgabus_12, io_ss => fpgabus_13,
            io_mosi => fpgabus_10, io_miso => fpgabus_11
            io_poke => fpgabus_1);

    fifo_cam_trans: entity work.STD_FIFO
        port map(CLK => fpgaclock, RST => rst,
            WriteEn => iCamTransW, DataIn => iCamTransD, Full => iCamTransF,
            ReadEn => oCamTransR, DataOut => oCamTransD, Empty => oCamTransE);

    fifo_trans_bnn: entity work.STD_FIFO
        port map(CLK => fpgaclock, RST => rst,
            WriteEn => iTransBnnW, DataIn => iTransBnnD, Full => iTransBnnF,
            ReadEn => oTransBnnR, DataOut => oTransBnnD, Empty => oTransBnnE);

    fifo_bnn_spi: entity work.STD_FIFO
        generic map(DATA_WIDTH => 10, FIFO_DEPTH => 32)
        port map(CLK => fpgaclock, RST => rst,
            WriteEn => iBnnSpiW, DataIn => iBnnSpiD, Full => iBnnSpiF,
            ReadEn => oBnnSpiR, DataOut => oBnnSpiD, Empty => oBnnSpiE);
end architecture behavior;
