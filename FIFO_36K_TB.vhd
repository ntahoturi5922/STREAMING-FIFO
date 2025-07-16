library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIFO_36K_tb is
end FIFO_36K_tb;

architecture Behavioral of FIFO_36K_tb is

    -- Component declaration
    component FIFO_36K
        Port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            din     : in  std_logic_vector(63 downto 0);
            dout    : out std_logic_vector(63 downto 0);
            empty   : out std_logic;
            full    : out std_logic;
            rerr    : out std_logic;
            rcount  : out std_logic_vector(13 downto 0);
            werr    : out std_logic;
            wcount  : out std_logic_vector(13 downto 0);
            wrst    : out std_logic;
            rrst    : out std_logic;
            wren    : in  std_logic;
            ren     : in  std_logic
        );
    end component;

    -- Signals for the DUT
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal din     : std_logic_vector(63 downto 0);
    signal dout    : std_logic_vector(63 downto 0);
    signal empty   : std_logic;
    signal full    : std_logic;
    signal rerr    : std_logic;
    signal rcount  : std_logic_vector(13 downto 0);
    signal werr    : std_logic;
    signal wcount  : std_logic_vector(13 downto 0);
    signal wrst    : std_logic;
    signal rrst    : std_logic;
    signal wren    : std_logic := '0';
    signal ren     : std_logic := '0';

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the DUT
    uut: FIFO_36K
        port map (
            clk     => clk,
            rst     => rst,
            din     => din,
            dout    => dout,
            empty   => empty,
            full    => full,
            rerr    => rerr,
            rcount  => rcount,
            werr    => werr,
            wcount  => wcount,
            wrst    => wrst,
            rrst    => rrst,
            wren    => wren,
            ren     => ren
        );

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset FIFO
       
            rst <= '1';
        
        wait until rising_edge(clk);
        
            rst <= '0';
       
       -- wait for clk_period;

        -- Write 5 values
        
    for i in 0 to 511 loop
        din <= std_logic_vector(to_unsigned(i, 64)) ; -- pad 64b to 72b if needed
        wren <= '1';
        wait for clk_period;
    end loop;

        

        wren <= '0';
        wait until rising_edge(clk);
        --rst <= '1';
        -- Read 5 values
        
        for i in 0 to 511 loop
            ren <= '1';
            wait for clk_period;
        end loop;
      
        wait for clk_period;
        ren <= '0';

        -- Simulation end
        wait for 10ns;
       -- assert false report "Simulation ended." severity failure;
    end process;

end Behavioral;
