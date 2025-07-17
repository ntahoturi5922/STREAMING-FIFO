library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ==============================================
-- FIFO Component Declaration & Architecture
-- ==============================================
entity steam_fifo_test is
    generic (
        DATA_WIDTH : natural := 64;
        DEPTH      : natural := 64  -- 128 bytes = 32 x 4-byte words
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
 
        -- Write interface
        wr_en   : in  std_logic;
        din     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        full    : out std_logic;

        -- Read interface
        rd_en   : in  std_logic;
        dout    : out std_logic_vector(DATA_WIDTH-1 downto 0);
        empty   : out std_logic
    );
end entity;

architecture rtl of steam_fifo_test is
    type fifo_array is array(0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem     : fifo_array;
    signal rd_ptr  : integer range 0 to DEPTH-1 := 0;
    signal wr_ptr  : integer range 0 to DEPTH-1 := 0;
    signal count   : integer range 0 to DEPTH := 0;
    signal empty_reg,full_reg : std_logic ;
    signal dout_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rd_ptr <= 0;
                wr_ptr <= 0;
                count  <= 0;
                dout_reg <= (others => '0');
            else
                -- Write logic
                if wr_en = '1' and full_reg = '0' then
                    mem(wr_ptr) <= din;
                    wr_ptr <= (wr_ptr + 1) mod DEPTH;
                    count <= count + 1;
                end if;

                -- Read logic
                if rd_en = '1' and empty_reg = '0' then
                    dout_reg <= mem(rd_ptr);
                    rd_ptr <= (rd_ptr + 1) mod DEPTH;
                    count <= count - 1;
                end if;
            end if;
        end if;
    end process;

    dout  <= dout_reg;
    full_reg  <= '1' when count = DEPTH else '0';
    empty_reg <= '1' when count = 0     else '0';
    full <= full_reg;
    empty <= empty_reg;

end architecture;
