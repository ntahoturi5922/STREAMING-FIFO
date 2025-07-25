library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ==============================================
-- AXI Stream Counter with FIFO
-- ==============================================
entity axis_steam is
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
        m_axis_tkeep  : out std_logic_vector (3 downto 0)
    );
end entity;

architecture behavioral of axis_steam is

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
begin
    fifo_rst_reg <= not aresetn;
    -- =======================
    -- FIFO Instance
    -- =======================
    fifo_inst: entity work.steam_fifo_test
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            DEPTH      => 32  -- 128 bytes = 32 x 4-byte words
        )
        port map (
            clk     => clk,
            rst     => fifo_rst_reg,
            wr_en   => fifo_wr_en,
            din     => fifo_din,
            full    => fifo_full,
            rd_en   => fifo_rd_en,
            dout    => fifo_dout,
            empty   => fifo_empty
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
    -- Counter & FIFO Write Logic
    -- =======================
    process(clk, aresetn)
    begin
        if aresetn = '0' then
            counter <= (others => '0');
            fifo_wr_en <= '0';
            fifo_din <= (others => '0');
            data_out_last <= '0';
        elsif rising_edge(clk) then
            if data_in_valid = '1' and fifo_full = '0' then
                fifo_wr_en <= '1';
                fifo_din <= std_logic_vector(resize(counter, DATA_WIDTH));
                counter <= counter + 1;

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
