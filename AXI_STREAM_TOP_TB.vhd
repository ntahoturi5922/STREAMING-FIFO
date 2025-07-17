----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/17/2025 02:52:10 PM
-- Design Name: 
-- Module Name: AXI_STREAM_TOP_TB - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity AXI_STREAM_TOP_TB is
end AXI_STREAM_TOP_TB;

architecture Behavioral of AXI_STREAM_TOP_TB is

    -- Constants
    constant C_S_AXI_DATA_WIDTH : integer := 32;
    constant C_S_AXI_ADDR_WIDTH : integer := 6;
    constant DATA_WIDTH         : natural := 64;
    constant CLK_PERIOD         : time := 10 ns;

    -- Signals
    signal S_AXI_ACLK      : std_logic := '0';
    signal S_AXI_ARESETN   : std_logic := '0';

    -- AXI-Lite interface
    signal S_AXI_AWADDR    : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal S_AXI_AWPROT    : std_logic_vector(2 downto 0) := (others => '0');
    signal S_AXI_AWVALID   : std_logic := '0';
    signal S_AXI_AWREADY   : std_logic;
    signal S_AXI_WDATA     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal S_AXI_WSTRB     : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0) := (others => '1');
    signal S_AXI_WVALID    : std_logic := '0';
    signal S_AXI_WREADY    : std_logic;
    signal S_AXI_BRESP     : std_logic_vector(1 downto 0);
    signal S_AXI_BVALID    : std_logic;
    signal S_AXI_BREADY    : std_logic := '1';
    signal S_AXI_ARADDR    : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal S_AXI_ARPROT    : std_logic_vector(2 downto 0) := (others => '0');
    signal S_AXI_ARVALID   : std_logic := '0';
    signal S_AXI_ARREADY   : std_logic;
    signal S_AXI_RDATA     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal S_AXI_RRESP     : std_logic_vector(1 downto 0);
    signal S_AXI_RVALID    : std_logic;
    signal S_AXI_RREADY    : std_logic := '1';

    -- AXI Stream interface
    signal s_axis_tvalid   : std_logic := '0';
    signal s_axis_tready   : std_logic;
    signal s_axis_tdata    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal s_axis_tlast    : std_logic := '0';
    signal s_axis_tkeep    : std_logic_vector(3 downto 0) := (others => '1');
    signal m_axis_tvalid   : std_logic;
    signal m_axis_tready   : std_logic := '1';
    signal m_axis_tdata    : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal m_axis_tlast    : std_logic;
    signal m_axis_tkeep    : std_logic_vector(3 downto 0);

    -- Status signals
    signal rerr, werr, wrst, rrst : std_logic;
    signal rcount, wcount         : std_logic_vector(13 downto 0);

begin

    -- DUT Instantiation
    uut: entity work.AXI_STREAM_TOP
        generic map (
            C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
            DATA_WIDTH         => DATA_WIDTH
        )
        port map (
            S_AXI_ACLK      => S_AXI_ACLK,
            S_AXI_ARESETN   => S_AXI_ARESETN,
            S_AXI_AWADDR    => S_AXI_AWADDR,
            S_AXI_AWPROT    => S_AXI_AWPROT,
            S_AXI_AWVALID   => S_AXI_AWVALID,
            S_AXI_AWREADY   => S_AXI_AWREADY,
            S_AXI_WDATA     => S_AXI_WDATA,
            S_AXI_WSTRB     => S_AXI_WSTRB,
            S_AXI_WVALID    => S_AXI_WVALID,
            S_AXI_WREADY    => S_AXI_WREADY,
            S_AXI_BRESP     => S_AXI_BRESP,
            S_AXI_BVALID    => S_AXI_BVALID,
            S_AXI_BREADY    => S_AXI_BREADY,
            S_AXI_ARADDR    => S_AXI_ARADDR,
            S_AXI_ARPROT    => S_AXI_ARPROT,
            S_AXI_ARVALID   => S_AXI_ARVALID,
            S_AXI_ARREADY   => S_AXI_ARREADY,
            S_AXI_RDATA     => S_AXI_RDATA,
            S_AXI_RRESP     => S_AXI_RRESP,
            S_AXI_RVALID    => S_AXI_RVALID,
            S_AXI_RREADY    => S_AXI_RREADY,

            s_axis_tvalid   => s_axis_tvalid,
            s_axis_tready   => s_axis_tready,
            s_axis_tdata    => s_axis_tdata,
            s_axis_tlast    => s_axis_tlast,
            s_axis_tkeep    => s_axis_tkeep,

            m_axis_tvalid   => m_axis_tvalid,
            m_axis_tready   => m_axis_tready,
            m_axis_tdata    => m_axis_tdata,
            m_axis_tlast    => m_axis_tlast,
            m_axis_tkeep    => m_axis_tkeep,

            rerr            => rerr,
            rcount          => rcount,
            werr            => werr,
            wcount          => wcount,
            wrst            => wrst,
            rrst            => rrst
        );

    -- Clock generation
    clk_proc : process
    begin
        while true loop
            S_AXI_ACLK <= '0';
            wait for CLK_PERIOD / 2;
            S_AXI_ACLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

 stim_proc : process
    variable read_result : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
begin
    -- Reset
    S_AXI_ARESETN <= '0';
    wait for 30 ns;
    S_AXI_ARESETN <= '1';
    wait for 20 ns;

    ----------------------------------------------------------------
    -- AXI-Lite WRITE to registers 0 to 4
    ----------------------------------------------------------------
    for i in 0 to 4 loop
        -- Prepare write address and data
        S_AXI_AWADDR  <= std_logic_vector(to_unsigned(i * 4, C_S_AXI_ADDR_WIDTH));
        S_AXI_AWVALID <= '1';
        S_AXI_WDATA   <= std_logic_vector(to_unsigned((i+1)*16#11111111#, C_S_AXI_DATA_WIDTH)); -- e.g. 0x11111111, 0x22222222, ...
        S_AXI_WVALID  <= '1';

        -- Wait for AWREADY and WREADY handshake
        wait until rising_edge(S_AXI_ACLK) and S_AXI_AWREADY = '1';
        S_AXI_AWVALID <= '0';

        wait until rising_edge(S_AXI_ACLK) and S_AXI_WREADY = '1';
        S_AXI_WVALID <= '0';

        -- Wait for BVALID
        wait until rising_edge(S_AXI_ACLK) and S_AXI_BVALID = '1';
        wait for CLK_PERIOD;
    end loop;

    ----------------------------------------------------------------
    -- AXI-Lite READ from registers 0 to 4
    ----------------------------------------------------------------
    for i in 0 to 4 loop
        S_AXI_ARADDR  <= std_logic_vector(to_unsigned(i * 4, C_S_AXI_ADDR_WIDTH));
        S_AXI_ARVALID <= '1';

        wait until rising_edge(S_AXI_ACLK) and S_AXI_ARREADY = '1';
        S_AXI_ARVALID <= '0';

        wait until rising_edge(S_AXI_ACLK) and S_AXI_RVALID = '1';
        read_result := S_AXI_RDATA;
        report "Read from address " & integer'image(i * 4) & " = " & to_hstring(read_result);

        wait for CLK_PERIOD;
    end loop;

    ----------------------------------------------------------------
    -- AXI Stream Example
    ----------------------------------------------------------------
    s_axis_tdata  <= x"DEADBEEFCAFEBABE";
    s_axis_tvalid <= '1';
    s_axis_tlast  <= '1';

    wait until rising_edge(S_AXI_ACLK) and s_axis_tready = '1';
    s_axis_tvalid <= '0';
    s_axis_tlast  <= '0';

    wait for 100 ns;
    wait;
end process;

end Behavioral;




