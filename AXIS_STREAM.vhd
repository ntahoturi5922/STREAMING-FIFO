----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacques Ntahoturi
-- 
-- Create Date: 07/17/2025 08:37:00 AM
-- Design Name: 
-- Module Name: AXIS_STREAM_TB - Behavioral
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
-- -------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ==============================================
-- AXI Stream Counter with FIFO
-- ==============================================
entity AXIS_STREAM is
    generic ( 
        DATA_WIDTH    : natural := 64;
        COUNTER_WIDTH : natural := 64
    );
    port (
        -- Clock and Reset
        clk        : in  std_logic;
        aresetn    : in  std_logic;

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
end entity;

architecture behavioral of AXIS_STREAM is

    -- Internal signals
    signal counter         : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal data_in_valid   : std_logic := '0';
    signal data_out_last   : std_logic := '0';
    signal t_ready_reg     : std_logic;
    signal t_valid_reg     : std_logic ;
    -- FIFO signals
    signal fifo_wr_en  : std_logic;
    signal fifo_rd_en  : std_logic;
    signal fifo_din    : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_dout   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_full   : std_logic;
    signal fifo_empty  : std_logic;
    signal fifo_rst_reg: std_logic ;
   --flags
    signal fifo_rerr:  std_logic ;
    signal fifo_rcount:  std_logic_vector (13 downto 0);
    signal fifo_werr:  std_logic ;
    signal fifo_wcount:  std_logic_vector (13 downto 0);
    signal fifo_wrst:  std_logic ;
    signal fifo_rrst:  std_logic ;
begin
    fifo_rst_reg <= not aresetn;
    -- ======================= 
    -- FIFO Instance
    -- =======================
    fifo_inst: entity work.FIFO_36K 

        port map (
            clk     => clk,
            rst     => fifo_rst_reg,
            wren   => fifo_wr_en,
            din     => fifo_din,
            full    => fifo_full,
            ren   => fifo_rd_en,
            dout    => fifo_dout,
            empty   => fifo_empty,
  --flags 
            rerr => fifo_rerr ,
            rcount => fifo_rcount, 
            werr => fifo_werr ,
            wcount => fifo_wcount ,
            wrst => fifo_wrst ,
            rrst=> fifo_rrst 
  -- controll signals
             
        );

    -- =======================
    -- Input Valid Logic
    -- =======================
    process(clk, aresetn)
    begin
        if aresetn = '0' then
            data_in_valid <= '0';
        elsif rising_edge(clk) then
            if s_axis_tvalid = '1' and t_ready_reg = '1' and s_axis_tkeep = x"f" then
                data_in_valid <= '1';
            else
                data_in_valid <= '0';
            end if;
        end if;
    end process;

    -- =======================
    --FIFO Write Logic
    -- =======================
    process(clk, aresetn)
    begin
        if aresetn = '0' then
            --counter <= (others => '0');
            fifo_wr_en <= '0';
            fifo_din <= (others => '0');
            data_out_last <= '0';
        elsif rising_edge(clk) then
            if data_in_valid = '1' and fifo_full = '0' then
                fifo_wr_en <= '1';
                fifo_din <= s_axis_tdata;
               -- counter <= counter + 1;

                if s_axis_tlast = '1' then
                    data_out_last <= '1';
                else
                    data_out_last <= '0';
                end if;
            else
                fifo_wr_en <= '0';
            end if;
        end if;
    end process;

    -- =======================
    -- FIFO Read Logic
    -- =======================
    fifo_rd_en <= '1' when (m_axis_tready = '1' and fifo_empty = '0') else '0';
   t_valid_reg <= not fifo_empty;
    -- =======================
    -- Output Assignment
    -- =======================
    t_ready_reg     <= not fifo_full;
    s_axis_tready   <= t_ready_reg;
    m_axis_tvalid   <= t_valid_reg ;
    m_axis_tdata    <= fifo_dout;
    m_axis_tlast    <= data_out_last;
     m_axis_tkeep <= x"f" when t_valid_reg = '1' else x"0";
end architecture;
