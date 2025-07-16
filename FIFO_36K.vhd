----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacques Ntahoturi
-- 
-- Create Date: 07/16/2025 12:49:24 PM
-- Design Name: 
-- Module Name: FIFO_36K - Behavioral
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
Library UNISIM;
use UNISIM.vcomponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FIFO_36K is
  Port (
  clk :in std_logic ;
  rst: in std_logic ;
  din: in std_logic_vector (63 downto 0);
  dout: out std_logic_vector (63 downto 0);
  
  --flags
  empty: out std_logic ;
  full: out std_logic ;
  rerr: out std_logic ;
  rcount: out std_logic_vector (13 downto 0);
  werr: out std_logic ;
  wcount: out std_logic_vector (13 downto 0);
  wrst: out std_logic ;
  rrst: out std_logic ;
  -- controll signals
  wren: in std_logic ;
  ren: in std_logic 
   );
end FIFO_36K;

architecture Behavioral of FIFO_36K is
signal rclk : std_logic ;
begin
rclk <= not clk;
   FIFO36E2_inst : FIFO36E2
   generic map (
      CASCADE_ORDER => "NONE",            -- FIRST, LAST, MIDDLE, NONE, PARALLEL
      CLOCK_DOMAINS => "INDEPENDENT",     -- COMMON, INDEPENDENT
      EN_ECC_PIPE => "FALSE",             -- ECC pipeline register, (FALSE, TRUE)
      EN_ECC_READ => "TRUE",             -- Enable ECC decoder, (FALSE, TRUE)
      EN_ECC_WRITE => "TRUE",            -- Enable ECC encoder, (FALSE, TRUE)
      FIRST_WORD_FALL_THROUGH => "TRUE", -- FALSE, TRUE
      INIT => X"00BABADADACACAFAFA",      -- Initial values on output port
      PROG_EMPTY_THRESH => 256,           -- Programmable Empty Threshold
      PROG_FULL_THRESH => 256,            -- Programmable Full Threshold
      -- Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
      IS_RDCLK_INVERTED => '0',           -- Optional inversion for RDCLK
      IS_RDEN_INVERTED => '0',            -- Optional inversion for RDEN
      IS_RSTREG_INVERTED => '0',          -- Optional inversion for RSTREG
      IS_RST_INVERTED => '0',             -- Optional inversion for RST
      IS_WRCLK_INVERTED => '0',           -- Optional inversion for WRCLK
      IS_WREN_INVERTED => '0',            -- Optional inversion for WREN
      RDCOUNT_TYPE => "RAW_PNTR",         -- EXTENDED_DATACOUNT, RAW_PNTR, SIMPLE_DATACOUNT, SYNC_PNTR
      READ_WIDTH => 72,                    -- 18-9
      REGISTER_MODE => "UNREGISTERED",    -- DO_PIPELINED, REGISTERED, UNREGISTERED
      RSTREG_PRIORITY => "REGCE",        -- REGCE, RSTREG
      SLEEP_ASYNC => "FALSE",             -- FALSE, TRUE
      SRVAL => X"000000000000000000",     -- SET/reset value of the FIFO outputs
      WRCOUNT_TYPE => "RAW_PNTR",         -- EXTENDED_DATACOUNT, RAW_PNTR, SIMPLE_DATACOUNT, SYNC_PNTR
      WRITE_WIDTH => 72                    -- 18-9
   )
   port map (
      -- Cascade Signals outputs: Multi-FIFO cascade signals
      CASDOUT => open,             -- 64-bit output: Data cascade output bus
      CASDOUTP => open,           -- 8-bit output: Parity data cascade output bus
      CASNXTEMPTY => open,     -- 1-bit output: Cascade next empty
      CASPRVRDEN => open,       -- 1-bit output: Cascade previous read enable
      -- ECC Signals outputs: Error Correction Circuitry ports
      DBITERR => open,             -- 1-bit output: Double bit error status
      ECCPARITY => open,         -- 8-bit output: Generated error correction parity
      SBITERR => open,             -- 1-bit output: Single bit error status
      -- Read Data outputs: Read output data
      DOUT => dout,                   -- 64-bit output: FIFO data output bus
      DOUTP => open,                 -- 8-bit output: FIFO parity output bus.
      -- Status outputs: Flags and other FIFO status outputs
      EMPTY => empty,                 -- 1-bit output: Empty
      FULL => full,                   -- 1-bit output: Full
      PROGEMPTY => open,         -- 1-bit output: Programmable empty
      PROGFULL => open,           -- 1-bit output: Programmable full
      RDCOUNT => rcount,             -- 14-bit output: Read count
      RDERR => rerr,                 -- 1-bit output: Read error
      RDRSTBUSY => rrst,         -- 1-bit output: Reset busy (sync to RDCLK)
      WRCOUNT => wcount,             -- 14-bit output: Write count
      WRERR => werr,                 -- 1-bit output: Write Error
      WRRSTBUSY => wrst,         -- 1-bit output: Reset busy (sync to WRCLK)
      -- Cascade Signals inputs: Multi-FIFO cascade signals
      CASDIN => x"0000000000000000",               -- 64-bit input: Data cascade input bus
      CASDINP => x"00",             -- 8-bit input: Parity data cascade input bus
      CASDOMUX => '0',           -- 1-bit input: Cascade MUX select input
      CASDOMUXEN => '0',       -- 1-bit input: Enable for cascade MUX select
      CASNXTRDEN => '0',       -- 1-bit input: Cascade next read enable
      CASOREGIMUX => '0',     -- 1-bit input: Cascade output MUX select
      CASOREGIMUXEN => '0', -- 1-bit input: Cascade output MUX select enable
      CASPRVEMPTY => '0',     -- 1-bit input: Cascade previous empty
      -- ECC Signals inputs: Error Correction Circuitry ports
      INJECTDBITERR => '0', -- 1-bit input: Inject a double-bit error
      INJECTSBITERR => '0', -- 1-bit input: Inject a single bit error
      -- Read Control Signals inputs: Read clock, enable and reset input signals
      RDCLK => clk,                 -- 1-bit input: Read clock
      RDEN => ren,                   -- 1-bit input: Read enable
      REGCE => '1',                 -- 1-bit input: Output register clock enable
      RSTREG => '0',               -- 1-bit input: Output register reset
      SLEEP => '0',                 -- 1-bit input: Sleep Mode
      -- Write Control Signals inputs: Write clock and enable input signals
      RST => rst,                     -- 1-bit input: Reset
      WRCLK => clk,                 -- 1-bit input: Write clock
      WREN => wren,                   -- 1-bit input: Write enable
      -- Write Data inputs: Write input data
      DIN => din,                     -- 64-bit input: FIFO data input bus
      DINP => x"00"                    -- 8-bit input: FIFO parity input bus
   );

   -- End of FIFO36E2_inst instantiation

end Behavioral;
