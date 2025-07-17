library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity axis_steam_tb is
end axis_steam_tb;

architecture behavior of axis_steam_tb is

    -- Constants
    constant DATA_WIDTH    : natural := 64;
    constant COUNTER_WIDTH : natural := 64;

    -- Clock and Reset
    signal clk     : std_logic := '0';
    signal aresetn : std_logic := '0';

    -- AXIS Input
    signal s_axis_tvalid : std_logic := '0';
    signal s_axis_tready : std_logic;
    signal s_axis_tdata  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal s_axis_tlast  : std_logic := '0';
    signal s_axis_tkeep  : std_logic_vector (3 downto 0);
    -- AXIS Output
    signal m_axis_tvalid : std_logic;
    signal m_axis_tready : std_logic := '1';
    signal m_axis_tdata  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal m_axis_tlast  : std_logic;
    signal m_axis_tkeep  : std_logic_vector (3 downto 0);
    
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- DUT instance
    uut: entity work.axis_steam
        generic map (
            DATA_WIDTH    => DATA_WIDTH,
            COUNTER_WIDTH => COUNTER_WIDTH
        )
        port map (
            clk             => clk,
            aresetn         => aresetn,
            s_axis_tvalid   => s_axis_tvalid,
            s_axis_tready   => s_axis_tready,
            s_axis_tdata    => s_axis_tdata,
            s_axis_tlast    => s_axis_tlast,
            m_axis_tvalid   => m_axis_tvalid,
            m_axis_tready   => m_axis_tready,
            m_axis_tdata    => m_axis_tdata,
            m_axis_tlast    => m_axis_tlast,
            s_axis_tkeep    => s_axis_tkeep,
            m_axis_tkeep    => m_axis_tkeep
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        aresetn <= '0';
        wait for 20 ns;
        aresetn <= '1';

        -- Wait a bit after reset
        wait for 20 ns;

        -- Send a few valid transactions
        for i in 0 to 63 loop
            wait until rising_edge(clk);
            s_axis_tvalid <= '1';
            s_axis_tkeep   <= x"f";
            s_axis_tdata  <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
            if i = 15 then
                s_axis_tlast <= '1';
            else
                s_axis_tlast <= '0';
            end if;

            -- Wait until slave accepts the transaction
            wait until rising_edge(clk) and s_axis_tready = '1';
        end loop;

        s_axis_tvalid <= '0';
        s_axis_tkeep <= x"0";
        s_axis_tlast  <= '0';

        -- Let data flush out
        wait for 10 ns;

        -- Done
       
    end process;

    -- Monitor process (optional for simulation logs)
monitor_proc: process
    variable count  : integer := 0;
    variable suffix : string(1 to 7);  -- Adjust size if needed
    begin
        wait until aresetn = '1';
        wait for 10 ns;

    while true loop
        wait until rising_edge(clk);
        if m_axis_tvalid = '1' and m_axis_tready = '1' then
            if m_axis_tlast = '1' then
                suffix := " (last)";
            else
                suffix := "       "; -- same length, for alignment
            end if;

            report "Output: " & integer'image(to_integer(unsigned(m_axis_tdata))) & suffix;
            count := count + 1;
        end if;
    end loop;
    end process;

end architecture;
