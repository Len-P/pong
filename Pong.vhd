library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Pong is
    port ( Clk: in  std_logic;
           BTNLU: in std_logic;
           BTNLD: in std_logic;
           BTNRU: in std_logic;
           BTNRD: in std_logic;
           DIP15: in std_logic;
           DIP0: in std_logic;
           LED15: out std_logic := '0';
           LED0: out std_logic := '0';
           HS: out std_logic; -- actief laag
           VS: out std_logic;
           R: out std_logic_vector(3 downto 0);
           G: out std_logic_vector(3 downto 0);
           B: out std_logic_vector(3 downto 0);
           Cat: out std_logic_vector(6 downto 0);
           An: out std_logic_vector(7 downto 0));
end Pong;

architecture Behavioral of Pong is
    
    signal ClkCount: integer range 0 to 3 := 0;
    signal HCount: integer range 0 to 799 := 0;
    signal VCount: integer range 0 to 524 := 0;
    
    signal VideoActive: boolean := false;
    
    signal HSS: std_logic := '1';
    signal VSS: std_logic := '1';
    
    signal X: integer range 0 to 751;
    signal Y: integer range 0 to 491;
    
    signal XB: integer range 0 to 639 := 320; -- scherm is 640 breed
    signal XL: integer range 0 to 639 := 44; -- score zone + rand is 45 pixels breed (X van pallet ligt telkens naar het veld toe)
    signal XR: integer range 0 to 639 := 595;
    signal YB: integer range 0 to 479 := 240;
    signal YL: integer range 0 to 479 := 240;
    signal YR: integer range 0 to 479 := 240;
    
    signal ClkCountMovement: integer range 0 to 399_999 := 0;
    signal ClkCountBal: integer range 0 to 1 := 0;
    signal CountStat: integer range 0 to 499 := 0;
    
    type type_direction is (leftup, leftdown, rightup, rightdown, stationary);
    signal direction: type_direction := stationary;
    signal startDirNum: integer range 0 to 3 := 0;

    signal scoreL: unsigned(6 downto 0) := "0000000";
    signal scoreR: unsigned(6 downto 0) := "0000000";
    
    signal powerCountL: integer range 0 to 3 := 0;
    signal powerCountR: integer range 0 to 3 := 0;
    
    signal powerL: boolean := false;
    signal powerR: boolean := false;
    
    component Scorebord is
        port ( score1: unsigned(6 downto 0);    
               score2: unsigned(6 downto 0);  
               ClkS: std_logic;
               CatS: out std_logic_vector(6 downto 0);
               AnS: out std_logic_vector(7 downto 0));
    end component;

begin

   ------------------------------------------------- SCHERM --------------------------------------------------
   SeqProc: process(Clk)
        begin
            if rising_edge(Clk) then
            
                if ClkCount = 3 then
                    ClkCount <= 0;
                    
                    if HCount = 799 then
                        HCount <= 0;
                        
                        if VCount = 524 then --VCount stijgt wanneer HCount omklapt
                            VCount <= 0;
                        else
                            VCount <= VCount + 1;
                        end if;
                    
                    else              
                        HCount <= HCount + 1;      
                    end if;  
                    
                else
                    ClkCount <= ClkCount + 1;
                end if;

            end if;
    end process SeqProc;
    
    
    
    HSync: process(HCount)
    begin
        if HCount >= 704 then --sync pulse
            HSS <= '0';
        else
            HSS <= '1';
        end if;    
    
    end process HSync;
    
    
    
    VSync: process(VCount)
    begin
    
        if VCount >= 523 then --sync pulse 
            VSS <= '0';
        else
            VSS <= '1';
        end if;    
    
    end process VSync;    
    
    
    
    VA: process(HCount, VCount)
    begin
     
        if HCount >= 48 and HCount < 688 and VCount >= 33 and VCount < 513 then --hier mag rgb actief zijn (tss front en back porch)
            VideoActive <= true;
        else
            VideoActive <= false; 
        end if;
    
    end process VA;  
    
    HS <= HSS;
    VS <= VSS;
    -----------------------------------------------------------------------------------------------------------
    
    -------------------------------------------------- PONG ---------------------------------------------------    
    X <= HCount - 48; -- X en Y invoeren om gemakkelijker te werken met coordinaten (opgepast: X en Y zullen boven 639 en 479 gaan)
    Y <= VCount - 33;
    
    ---------------------------------- RGB ----------------------------------
    RGB: process(X, Y, VideoActive, XL, XR, XB, YL, YR, YB, powerL, powerR, powerCountL, powerCountR)
    begin

        if VideoActive then
            if (Y >= 0 and Y < 5) or --bovenrand
               (Y > 475 and Y <= 480) or --onderrand
               (X >= 0 and X < 5) or --linkerrand
               (X > 634 and X <= 639) or --rechterrand
               (X = 320) or --middellijn
               (Y - YL >= -14 and Y - YL <= 14 and X - XL >= -4 and X - XL <= 0) or --linkerpalet (29 hoog, 5 breed)
               (Y - YR >= -14 and Y - YR <= 14 and X - XR >= 0 and X - XR <= 4) or --rechterpalet (29 hoog, 5 breed)
               (Y - YB >= -2 and Y - YB <= 2 and X - XB >= -2 and X - XB <= 2) then --bal (5 hoog, 5 breed)
               
                R <= "1111";
                G <= "1111";
                B <= "1111";   
                
            elsif (powerCountL = 3 and (16 <= X and X <= 20) and ((24 <= Y and Y <= 34) or (37 <= Y and Y <= 39))) or --uitroepteken wanneer powerup ready is
                  (powerCountR = 3 and (619 <= X and X <= 623) and ((24 <= Y and Y <= 34) or (37 <= Y and Y <= 39))) then
                  
                R <= "0000"; 
                G <= "1111"; 
                B <= "0000"; 
                
            elsif ( powerR and ( ((X = 15 or X = 21) and (Y = 28 or Y = 36)) or ((X = 16 or X = 20) and ((27 <= Y and Y <= 28) or (36 <= Y and Y <= 37))) or ((X = 17 or X= 19) and 26 <= Y and Y <= 38) or (X = 18 and 25 <= Y and Y <= 39) ) ) or --dubbele pijl wanneer power op je gebruikt wordt
                  ( powerL and ( ((X = 618 or X = 624) and (Y = 28 or Y = 36)) or ((X = 619 or X = 623) and ((27 <= Y and Y <= 28) or (36 <= Y and Y <= 37))) or ((X = 620 or X= 622) and 26 <= Y and Y <= 38) or (X = 621 and 25 <= Y and Y <= 39) ) ) then
                  
                R <= "1111"; 
                G <= "0000"; 
                B <= "0000"; 
                            
            else
                R <= "0000"; 
                G <= "0000"; 
                B <= "0000"; 
            end if;
                               
        else
            R <= "0000"; 
            G <= "0000"; 
            B <= "0000"; 
        end if;
    
    end process RGB;  
    -----------------------------------------------------------------------------
    
    ------------------------------ BEWEGING + SCORE + POWERS -----------------------------
    SeqProcMovement: process(Clk)
        begin
            if rising_edge(Clk) then
            
                if ClkCountMovement = 399_999 then -- clockfrequentie verkleinen zodat palletjes met een controleerbare snelheid bewegen
                    ClkCountMovement <= 0;
                
                    --------------------------------- PALLETJES ---------------------------------
                    if (BTNLU = '1' and BTNLD = '1') or (BTNLU = '1' and BTNLD = '0' and YL < 19 and not powerR) or (BTNLU = '0' and BTNLD = '1' and YL > 461 and not powerR) then --19 en 461 zijn limieten voor palletcentrum
                        YL <= YL;     
                    elsif BTNLU = '1' and BTNLD = '0' and powerR then
                        if YL > 461 then
                            YL <= YL; 
                        else 
                            YL <= YL + 1;  
                        end if;     
                    elsif BTNLU = '0' and BTNLD = '1' and powerR then  
                        if YL < 19 then
                            YL <= YL; 
                        else 
                            YL <= YL - 1;  
                        end if;   
                    elsif BTNLU = '1' and BTNLD = '0' and not powerR then
                        YL <= YL - 1;    
                    elsif BTNLU = '0' and BTNLD = '1' and not powerR then  
                        YL <= YL + 1;    
                    end if;    
            
                    if (BTNRU = '1' and BTNRD = '1') or (BTNRU = '1' and BTNRD = '0' and YR < 19 and not powerL) or (BTNRU = '0' and BTNRD = '1' and YR > 461 and not powerL) then --19 en 461 zijn limieten voor palletcentrum
                        YR <= YR;     
                    elsif BTNRU = '1' and BTNRD = '0' and powerL then
                        if YR > 461 then
                            YR <= YR; 
                        else 
                            YR <= YR + 1;  
                        end if;  
                    elsif BTNRU = '0' and BTNRD = '1' and powerL then  
                        if YR < 19 then
                            YR <= YR; 
                        else 
                            YR <= YR - 1;  
                        end if;   
                    elsif BTNRU = '1' and BTNRD = '0' and not powerL then
                        YR <= YR - 1;    
                    elsif BTNRU = '0' and BTNRD = '1' and not powerL then  
                        YR <= YR + 1;    
                    end if;               
                    -----------------------------------------------------------------------------
                    
                    -------------------------------- BAL + SCORE --------------------------------
                    if direction = stationary then
                    -------------------------- STATIONARY BALL --------------------------
                        if CountStat = 499 then -- bal staat even stil na gescoord te hebben
                            CountStat <= 0; 
                            startDirNum <= startDirNum + 1;
                            
                            if startDirNum = 0 then -- cyclen door de mogelijke richtingen zodat de beginrichting elke ronde verandert
                                direction <= leftdown;
                            elsif startDirNum = 1 then
                                direction <= rightup;
                            elsif startDirNum = 2 then
                                direction <= rightdown;
                            elsif startDirNum = 3 then
                                direction <= leftup;
                                startDirNum <= 0;
                            end if;
                            
                        else
                        CountStat <= CountStat + 1;
                        direction <= stationary;
                        end if; 
                    ---------------------------------------------------------------------
                    elsif direction = leftup and YB = 7 then
                        direction <= leftdown;
                    elsif direction = rightup and YB = 7 then
                        direction <= rightdown;   
                    elsif direction = leftdown and YB = 473 then
                        direction <= leftup; 
                    elsif direction = rightdown and YB = 473 then
                        direction <= rightup;   
                        
                    elsif XB = XL + 3 and YL <= YB + 16 and YL >= YB - 16 then --botsing met linkerpallet
                        if direction = leftup then
                            direction <= rightup;
                        elsif direction = leftdown then
                            direction <= rightdown;
                        end if; 
                         
                    elsif XB = XR - 3 and YR <= YB + 16 and YR >= YB - 16 then --botsing met rechterpallet
                        if direction = rightup then
                            direction <= leftdown;
                        elsif direction = rightdown then
                            direction <= leftup;
                        end if; 
                             
                    end if;
                    
                    if ClkCountBal = 1 then -- clockfrequentie verkleinen zodat bal trager dan palletjes beweegt
                        ClkCountBal <= 0;
                        
                        if XB < 10 then -- checken of er gescoord (bal in scorezone) is, indien ja: bal terugzetten en score geven
			                XB <= 320;
                            YB <= 240;
                            scoreR <= scoreR + 1;
                            direction <= stationary;
                            powerCountR <= 0;
                            LED0 <= '0';
                            
                            if powerCountL = 3 then
                                powerCountL <= powerCountL;
                                LED15 <= '1';
                            else
                                powerCountL <= powerCountL + 1;	
                                LED15 <= '0';
                            end if;
                            
                        elsif XB > 629 then 
                            XB <= 320;
                            YB <= 240;
		                    scoreL <= scoreL + 1;
		                    direction <= stationary;
		                    powerCountL <= 0;
		                    LED15 <= '0';	
		                    
		                    if powerCountR = 3 then
                                powerCountR <= powerCountR;
                                LED0 <= '1';
                            else
                                powerCountR <= powerCountR + 1;
                                LED0 <= '0';	
                            end if;
                            
                        elsif direction = leftup then
                            XB <= XB - 1;
                            YB <= YB - 1;    
                        elsif direction = leftdown then    
                            XB <= XB - 1;
                            YB <= YB + 1;   
                        elsif direction = rightup then    
                            XB <= XB + 1;
                            YB <= YB - 1;  
                        elsif direction = rightdown then    
                            XB <= XB + 1;
                            YB <= YB + 1; 
                        elsif direction = stationary then    
                            XB <= XB;
                            YB <= YB;         
                        end if;
                        
                    else
                    ClkCountBal <= ClkCountBal + 1;
                    end if;    
                    -----------------------------------------------------------------------------
                    
                    ----------------------------------- POWER -----------------------------------
                    if powerCountL = 3 and DIP15 = '1' then
                        powerL <= true;
                    else
                        powerL <= false;
                    end if;
                    
                    if powerCountR = 3 and DIP0 = '1' then
                        powerR <= true;
                    else
                        powerR <= false;
                    end if;
                    -----------------------------------------------------------------------------
                else
                    ClkCountMovement <= ClkCountMovement + 1;
                end if;

            end if;
    end process SeqProcMovement;
    -----------------------------------------------------------------------------
    
    --------------------------------- SCOREBORD ---------------------------------
    SB: Scorebord port map( 
        score1 => scoreL,
        score2 => scoreR,
        ClkS => Clk,
        CatS => Cat,
        AnS => An);
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------      
    
end Behavioral;
