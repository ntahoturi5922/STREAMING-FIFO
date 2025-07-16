----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/16/2025 03:42:01 PM
-- Design Name: 
-- Module Name: OUTPUT_MUX_TB - Behavioral
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


entity OUTPUT_MUX_TB is
-- Testbenches do not have ports
end OUTPUT_MUX_TB;

architecture Behavioral of OUTPUT_MUX_TB is

    -- Component Declaration of the Unit Under Test (UUT)
    component OUTPUT_MUX
        Port (
            sel        : in  std_logic;
            AXI_FIFO   : in  std_logic_vector(63 downto 0);
            STREAM_FIFO: in  std_logic_vector(63 downto 0);
            OUT_FIFO   : out std_logic_vector(63 downto 0)
        );
    end component;

    -- Testbench signals
    signal sel         : std_logic := '0';
    signal AXI_FIFO    : std_logic_vector(63 downto 0) := (others => '0');
    signal STREAM_FIFO : std_logic_vector(63 downto 0) := (others => '0');
    signal OUT_FIFO    : std_logic_vector(63 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: OUTPUT_MUX
        port map (
            sel         => sel,
            AXI_FIFO    => AXI_FIFO,
            STREAM_FIFO => STREAM_FIFO,
            OUT_FIFO    => OUT_FIFO
        );

    -- Stimulus process
    process
    begin
        -- Test case 1: sel = '0'
        AXI_FIFO    <= x"1111111111111111";
        STREAM_FIFO <= x"AAAAAAAAAAAAAAAA";
        sel <= '0';
        wait for 10 ns;

        -- Test case 2: sel = '1'
        sel <= '1';
        wait for 10 ns;

        -- Test case 3: Change inputs
        AXI_FIFO    <= x"2222222222222222";
        STREAM_FIFO <= x"BBBBBBBBBBBBBBBB";
        wait for 10 ns;

        -- Test case 4: Toggle select back to '0'
        sel <= '0';
        wait for 10 ns;

        -- Finish simulation
        wait;
    end process;
end Behavioral;




