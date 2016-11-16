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
          );
    -- TODO: Add SPI-bus to ports
end entity sudo_ku;

architecture behavior of sudo_ku is
    
    -- No CameraController-component, because it's already a VHDL entity and
    -- can be directly instantiated

    component Transformer is
        port(
            clk       : in std_logic;
            reset     : in std_logic;
            cam_read  : out std_logic;
            cam_data  : in std_logic_vector(0 downto 0);
            cam_empty : in std_logic;
            enable    : in std_logic;
            bnn_write : out std_logic;
            bnn_data  : out std_logic_vector(0 downto 0);
            bnn_full  : in std_logic
        );
    end component;

    component BNN is
        port(
            clk         : in std_logic;
            reset       : in std_logic;
            trans_read  : out std_logic;
            trans_data  : in std_logic_vector(0 downto 0);
            trans_empty : in std_logic;
            enable      : in std_logic;
            spi_write   : out std_logic;
            spi_data    : out std_logic_vector(9 downto 0);
            spi_full    : in std_logic
        );
    end component;

    component SpiSlave is
        port(
            clk       : in std_logic;
            reset     : in std_logic;
            bnn_read  : out std_logic;
            bnn_data  : in std_logic_vector(9 downto 0);
            bnn_empty : in std_logic;
            sclk      : in std_logic;
            mosi      : in std_logic;
            miso      : out std_logic;
            ss        : in std_logic
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
        port map(clk => fpgaclock, rst => rst,
            trans_write => iCamTransW, trans_data => iCamTransD,
            trans_full => iCamTransF);
        -- TODO: add CSI ports (and enable?)
    trans: Transformer
        port map(clk => fpgaclock, reset => rst,
            cam_read => oCamTransR, cam_data => oCamTransD,
            cam_empty => oCamTransE,
            bnn_write => iTransBnnW, bnn_data => iTransBnnD,
            bnn_full => iTransBnnF);
        -- TODO: add enable?
    bnn_inst: BNN
        port map(clk => fpgaclock, reset => rst,
            trans_read => oTransBnnR, trans_data => oTransBnnD,
            trans_empty => oTransBnnE,
            spi_write => iBnnSpiW, spi_data => iBnnSpiD,
            spi_full => iBnnSpiF);
        -- TODO: Ditto
    spi: SpiSlave
        port map(clk => fpgaclock, reset => rst,
            bnn_read => oBnnSpiR, bnn_data => oBnnSpiD,
            bnn_empty => oBnnSpiE);
        -- TODO: Figure out SPI-ports

    fifo_cam_trans: entity IEEE.STD_FIFO
        port map(CLK => fpgaclock, RST => rst,
            WriteEn => iCamTransW, DataIn => iCamTransD, Full => iCamTransF,
            ReadEn => oCamTransR, DataOut => oCamTransD, Empty => oCamTransE);

    fifo_trans_bnn: entity IEEE.STD_FIFO
        port map(CLK => fpgaclock, RST => rst,
            WriteEn => iTransBnnW, DataIn => iTransBnnD, Full => iTransBnnF,
            ReadEn => oTransBnnR, DataOut => oTransBnnD, Empty => oTransBnnE);

    fifo_bnn_spi: entity IEEE.STD_FIFO
        generic map(DATA_WIDTH => 10, FIFO_DEPTH => 32)
        port map(CLK => fpgaclock, RST => rst,
            WriteEn => iBnnSpiW, DataIn => iBnnSpiD, Full => iBnnSpiF,
            ReadEn => oBnnSpiR, DataOut => oBnnSpiD, Empty => oBnnSpiE);
end architecture behavior;
