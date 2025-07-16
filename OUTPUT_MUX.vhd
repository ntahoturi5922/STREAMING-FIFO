----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacques Ntahoturi
-- 
-- Create Date: 07/16/2025 03:26:59 PM
-- Design Name: 
-- Module Name: OUTPUT_MUX - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity OUTPUT_MUX is
    Port (
        sel   : in  std_logic;                         -- Select signal
        AXI_FIFO   : in  std_logic_vector(63 downto 0);     -- Input 0
        STREAM_FIFO   : in  std_logic_vector(63 downto 0);     -- Input 1
        OUT_FIFO  : out std_logic_vector(63 downto 0)      -- Output
    );
end OUTPUT_MUX;

architecture Behavioral of OUTPUT_MUX is

begin
    with sel select
        OUT_FIFO <= AXI_FIFO when '0',
                STREAM_FIFO when '1',
                (others => 'X') when others;
end Behavioral;

