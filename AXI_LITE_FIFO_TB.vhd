----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/16/2025 04:22:25 PM
-- Design Name: 
-- Module Name: AXI_LITE_FIFO_TB - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AXI_LITE_FIFO_TB is
end AXI_LITE_FIFO_TB;

architecture behavior of AXI_LITE_FIFO_TB is

  constant C_S_AXI_DATA_WIDTH : integer := 32;
  constant C_S_AXI_ADDR_WIDTH : integer := 6;

  -- DUT signals
  signal S_AXI_ACLK     : std_logic := '0';
  signal S_AXI_ARESETN  : std_logic := '0';
  signal S_AXI_AWADDR   : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal S_AXI_AWPROT   : std_logic_vector(2 downto 0);
  signal S_AXI_AWVALID  : std_logic;
  signal S_AXI_AWREADY  : std_logic;
  signal S_AXI_WDATA    : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal S_AXI_WSTRB    : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
  signal S_AXI_WVALID   : std_logic;
  signal S_AXI_WREADY   : std_logic;
  signal S_AXI_BRESP    : std_logic_vector(1 downto 0);
  signal S_AXI_BVALID   : std_logic;
  signal S_AXI_BREADY   : std_logic := '1';
  signal S_AXI_ARADDR   : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0):="000000";
  signal S_AXI_ARPROT   : std_logic_vector(2 downto 0);
  signal S_AXI_ARVALID  : std_logic:= '1';
  signal S_AXI_ARREADY  : std_logic;
  signal S_AXI_RDATA    : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal S_AXI_RRESP    : std_logic_vector(1 downto 0);
  signal S_AXI_RVALID   : std_logic;
  signal S_AXI_RREADY   : std_logic := '1';

  -- Outputs
  signal axi_fifo_data  : std_logic_vector(63 downto 0);
  signal fifo_sel       : std_logic;

  -- Clock generation
  constant CLK_PERIOD : time := 10 ns;

begin

  -- Instantiate DUT
  uut: entity work.AXI_LITE_FIFO
    generic map (
      C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
    )
    port map (
      S_AXI_ACLK     => S_AXI_ACLK,
      S_AXI_ARESETN  => S_AXI_ARESETN,
      S_AXI_AWADDR   => S_AXI_AWADDR,
      S_AXI_AWPROT   => S_AXI_AWPROT,
      S_AXI_AWVALID  => S_AXI_AWVALID,
      S_AXI_AWREADY  => S_AXI_AWREADY,
      S_AXI_WDATA    => S_AXI_WDATA,
      S_AXI_WSTRB    => S_AXI_WSTRB,
      S_AXI_WVALID   => S_AXI_WVALID,
      S_AXI_WREADY   => S_AXI_WREADY,
      S_AXI_BRESP    => S_AXI_BRESP,
      S_AXI_BVALID   => S_AXI_BVALID,
      S_AXI_BREADY   => S_AXI_BREADY,
      S_AXI_ARADDR   => S_AXI_ARADDR,
      S_AXI_ARPROT   => S_AXI_ARPROT,
      S_AXI_ARVALID  => S_AXI_ARVALID,
      S_AXI_ARREADY  => S_AXI_ARREADY,
      S_AXI_RDATA    => S_AXI_RDATA,
      S_AXI_RRESP    => S_AXI_RRESP,
      S_AXI_RVALID   => S_AXI_RVALID,
      S_AXI_RREADY   => S_AXI_RREADY,
      axi_fifo_data  => axi_fifo_data,
      fifo_sel       => fifo_sel
    );

  -- Clock process
  clk_process : process
  begin
    while true loop
      S_AXI_ACLK <= '0';
      wait for CLK_PERIOD / 2;
      S_AXI_ACLK <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- Stimulus
  stim_proc: process
  begin
    -- Reset
    S_AXI_ARESETN <= '0';
    wait for  CLK_PERIOD;
    S_AXI_ARESETN <= '1';
    wait for  CLK_PERIOD;

    -- Write to slv_reg0 (addr = 0)
    S_AXI_AWADDR  <= "000000";
    S_AXI_AWPROT  <= "111";
    S_AXI_AWVALID <= '1';
    S_AXI_WDATA   <= x"DEADBEEF";
    S_AXI_WSTRB   <= "1111";
    S_AXI_WVALID  <= '1';

    -- Wait for write handshake
    wait until S_AXI_AWREADY = '1' and S_AXI_WREADY = '1';
    S_AXI_AWVALID <= '0';
    S_AXI_WVALID  <= '0';

    wait until S_AXI_BVALID = '1';
    S_AXI_BREADY <= '1';

    -- Done
    wait for  CLK_PERIOD;

    -- Optional: Read back (if supported)
    S_AXI_ARADDR  <= "000000";
    S_AXI_ARPROT  <= "111";
    S_AXI_ARVALID <= '1';

    wait until S_AXI_ARREADY = '1';
    S_AXI_ARVALID <= '0';

    wait until S_AXI_RVALID = '1';
    S_AXI_RREADY  <= '1';
    wait for  CLK_PERIOD;


    -- Write to slv_reg0 (addr = 1)
    S_AXI_AWADDR  <= "000001";
    S_AXI_AWPROT  <= "000";
    S_AXI_AWVALID <= '1';
    S_AXI_WDATA   <= x"BABEBABE";
    S_AXI_WSTRB   <= "1111";
    S_AXI_WVALID  <= '1';

    -- Wait for write handshake
    wait until S_AXI_AWREADY = '1' and S_AXI_WREADY = '1';
    S_AXI_AWVALID <= '0';
    S_AXI_WVALID  <= '0';

    wait until S_AXI_BVALID = '1';
    S_AXI_BREADY <= '1';
    
     -- Done
    wait for  CLK_PERIOD;

    -- Optional: Read back (if supported)
    S_AXI_ARADDR  <= "000001";
    S_AXI_ARPROT  <= "000";
    S_AXI_ARVALID <= '1';

    wait until S_AXI_ARREADY = '1';
    S_AXI_ARVALID <= '0';

    wait until S_AXI_RVALID = '1';
    S_AXI_RREADY  <= '1';
   -- wait for  CLK_PERIOD;   
    -- End of test
    wait;
  end process;

end behavior;
