library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity BCD2SevenSegm is
    port ( BCD: in unsigned(3 downto 0);    
    SevenSegm: out std_logic_vector(6 downto 0));
end BCD2SevenSegm;


architecture Behavioral of BCD2SevenSegm is

    type tSegm is array(0 to 10) of std_logic_vector(6 downto 0);
    constant cSegm : tSegm := ("0000001", -- 0
                               "1001111", -- 1
                               "0010010", -- 2
                               "0000110", -- 3
                               "1001100", -- 4
                               "0100100", -- 5
                               "0100000", -- 6
                               "0001111", -- 7
                               "0000000", -- 8
                               "0000100", -- 9
                               "0110000"); -- error

begin

    SevenSegm <= cSegm(10) when BCD > 9 else
		         cSegm(to_integer(BCD));

end Behavioral;
