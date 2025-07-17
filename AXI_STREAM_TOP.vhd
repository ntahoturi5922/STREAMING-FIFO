----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/17/2025 11:58:28 AM
-- Design Name: 
-- Module Name: AXI_STREAM_TOP - Behavioral
-- Project Name: 
-- Target Devices: Jacques Ntahoturi
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity AXI_STREAM_TOP is
generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6;
		-- STREAM DATA WIDTH
		DATA_WIDTH    : natural := 64;
        COUNTER_WIDTH : natural := 64
	);
port (
		-- AXI-LITE interface
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
		
		
		-- stream interface
        -- AXI Stream Input
        s_axis_tvalid : in  std_logic;
        s_axis_tready : out std_logic;
        s_axis_tdata  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        s_axis_tlast  : in  std_logic;
        s_axis_tkeep  : in std_logic_vector (3 downto 0);

        -- AXI Stream Output
        m_axis_tvalid : out std_logic;
        m_axis_tready : in  std_logic;
        m_axis_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m_axis_tlast  : out std_logic;
        m_axis_tkeep  : out std_logic_vector (3 downto 0);
         
  
   --flags
        rerr: out std_logic ;
        rcount: out std_logic_vector (13 downto 0);
        werr: out std_logic ;
        wcount: out std_logic_vector (13 downto 0);
        wrst: out std_logic ;
        rrst: out std_logic  		
		);
end AXI_STREAM_TOP;

architecture Behavioral of AXI_STREAM_TOP is
-- SIGNALS GOES HERE
-- axilite signals

-- mux signals
        signal sel  :  std_logic;
        signal AXI_FIFO  : std_logic_vector(63 downto 0);
        signal STREAM_FIFO :std_logic_vector(63 downto 0);
        signal OUT_FIFO  :std_logic_vector(63 downto 0);
        signal axi_fifo_data: std_logic_vector(63 downto 0);
        signal fifo_sel: std_logic ;
--stream signals


begin
    fifo_inst: entity work.AXIS_STREAM
        -- Clock and Reset
port map(
        clk  =>  S_AXI_ACLK,     
        aresetn   =>  S_AXI_ARESETN,

        -- AXI Stream Input
        s_axis_tvalid  => s_axis_tvalid,
        s_axis_tready  => s_axis_tready,
        s_axis_tdata  =>  OUT_FIFO,
        s_axis_tlast => s_axis_tlast , 
        s_axis_tkeep  => s_axis_tkeep,

        -- AXI Stream Output
        m_axis_tvalid  => m_axis_tvalid,
        m_axis_tready =>  m_axis_tready,
        m_axis_tdata =>   m_axis_tdata,
        m_axis_tlast =>  m_axis_tlast,
        m_axis_tkeep =>  m_axis_tkeep,
         
  
   --flags
        rerr => rerr,
        rcount => rcount,
        werr => werr,
        wcount => wcount,
        wrst => wrst,
        rrst =>   rrst
    );     
    
 MUX_inst: entity work.OUTPUT_MUX
    port map(
        sel    => sel,
        AXI_FIFO   =>  axi_fifo_data,
        STREAM_FIFO  =>  s_axis_tdata ,
        OUT_FIFO    => OUT_FIFO
     
    
    );
 
 
 AXI_LITE_inst: entity work.AXI_LITE_FIFO
    port map(
		S_AXI_ACLK	 => S_AXI_ACLK,
		S_AXI_ARESETN	 => S_AXI_ARESETN,
		S_AXI_AWADDR	 => S_AXI_AWADDR,
		S_AXI_AWPROT	 => S_AXI_AWPROT,
		S_AXI_AWVALID	 => S_AXI_AWVALID,
		S_AXI_AWREADY	 => S_AXI_AWREADY,
		S_AXI_WDATA	 => S_AXI_WDATA,
		S_AXI_WSTRB	 => S_AXI_WSTRB,
		S_AXI_WVALID	 => S_AXI_WVALID,
		S_AXI_WREADY	 => S_AXI_WREADY,
		S_AXI_BRESP	 => S_AXI_BRESP,
		S_AXI_BVALID	 => S_AXI_BVALID,
		S_AXI_BREADY	 => S_AXI_BREADY,
		S_AXI_ARADDR	 => S_AXI_ARADDR,
		S_AXI_ARPROT	 => S_AXI_ARPROT,
		S_AXI_ARVALID	 => S_AXI_ARVALID,
		S_AXI_ARREADY	 => S_AXI_ARREADY,
		S_AXI_RDATA	 => S_AXI_RDATA,
		S_AXI_RRESP	 => S_AXI_RRESP,
		S_AXI_RVALID	 => S_AXI_RVALID,
		S_AXI_RREADY	 => S_AXI_RREADY,
        axi_fifo_data 	 => axi_fifo_data,
        fifo_sel    	 => fifo_sel
    
    );

end Behavioral;
