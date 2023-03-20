library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Scorebord is
    port ( score1: unsigned(6 downto 0);    
           score2: unsigned(6 downto 0);  
           ClkS: std_logic;
           CatS: out std_logic_vector(6 downto 0);
           AnS: out std_logic_vector(7 downto 0));
end Scorebord;

architecture Behavioral of Scorebord is

    component BCD2SevenSegm is -- BCD2SevenSegm in de architecture plaatsen
        port ( BCD: in unsigned(3 downto 0);
               SevenSegm: out std_logic_vector(6 downto 0));
    end component;

    signal leftbcd1 : unsigned(3 downto 0);
    signal leftbcd2 : unsigned(3 downto 0);
    signal leftled1: std_logic_vector(6 downto 0);
    signal leftled2: std_logic_vector(6 downto 0);
    
    signal rightbcd1 : unsigned(3 downto 0);
    signal rightbcd2 : unsigned(3 downto 0);
    signal rightled1 : std_logic_vector(6 downto 0);
    signal rightled2 : std_logic_vector(6 downto 0);
    
    signal ClkCount: integer range 0 to 12_499 := 0;
   
    signal AnSeq: std_logic_vector(7 downto 0) := "01111111";

begin

    leftbcd1 <= "0000" when 0 <= score1 and score1 <= 9 else
        "0001" when 10 <= score1 and score1 <= 19 else
        "0010" when 20 <= score1 and score1 <= 29 else
        "0011" when 30 <= score1 and score1 <= 39 else
        "0100" when 40 <= score1 and score1 <= 49 else
        "0101" when 50 <= score1 and score1 <= 59 else
        "0110" when 60 <= score1 and score1 <= 69 else
        "0111" when 70 <= score1 and score1 <= 79 else
        "1000" when 80 <= score1 and score1 <= 89 else
        "1001" when 90 <= score1 and score1 <= 99 else
        "1111";
      
    leftbcd2 <= to_unsigned(to_integer(score1 - leftbcd1*10), 4) when 0 <= score1 and score1 <= 99 else
                "1111";     

    rightbcd1 <= "0000" when 0 <= score2 and score2 <= 9 else
        "0001" when 10 <= score2 and score2 <= 19 else
        "0010" when 20 <= score2 and score2 <= 29 else
        "0011" when 30 <= score2 and score2 <= 39 else
        "0100" when 40 <= score2 and score2 <= 49 else
        "0101" when 50 <= score2 and score2 <= 59 else
        "0110" when 60 <= score2 and score2 <= 69 else
        "0111" when 70 <= score2 and score2 <= 79 else
        "1000" when 80 <= score2 and score2 <= 89 else
        "1001" when 90 <= score2 and score2 <= 99 else
        "1111";

    rightbcd2 <= to_unsigned(to_integer(score2 - rightbcd1*10), 4) when 0 <= score2 and score2 <= 99 else
                "1111";      

    LeftL1: BCD2SevenSegm port map( 
        BCD => leftbcd1,
        SevenSegm => leftled1);
        
    LeftL2: BCD2SevenSegm port map( 
        BCD => leftbcd2,
        SevenSegm => leftled2);        
        
    RightL1: BCD2SevenSegm port map( 
        BCD => rightbcd1,
        SevenSegm => rightled1);        
        
    RightL2: BCD2SevenSegm port map( 
        BCD => rightbcd2,
        SevenSegm => rightled2);   
        
   SeqProc: process(ClkS)
        begin
            if rising_edge(ClkS) then
            
                if ClkCount = 12_499 then 
                    ClkCount <= 0;
                    
                    if AnSeq(0) = '0' then -- shift naar rechts
                        AnSeq <= "01111111";
                    else
                        AnSeq <= '1' & AnSeq(7 downto 1);
                    end if;
                    
                else
                    ClkCount <= ClkCount + 1;
                end if;

            end if;
    end process SeqProc;   
     
    AnS <= AnSeq;
    CatS <= leftled1 when AnSeq = "01111111" else
           leftled2 when AnSeq = "10111111" else 
           rightled1 when AnSeq = "11111101" else 
           rightled2 when AnSeq = "11111110" else 
           "1111111";
        
end Behavioral;
