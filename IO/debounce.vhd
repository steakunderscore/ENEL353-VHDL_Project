----------------------------------------------------------------------------------
-- Module Name:    debounce
-- Description: Entity to debounce a mechanical switch/button
-- Authors: Tracy Jackson
--          Sasha Wang
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED."+";

library work;

ENTITY debounce IS
       PORT(clk : IN STD_LOGIC;
       switch : IN STD_LOGIC;
       switch_state : OUT STD_LOGIC);
END debounce;

ARCHITECTURE debounced_switch OF debounce IS
    SIGNAL count : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
     -- Debounce the switch using a counter
     PROCESS(clk, switch)
     BEGIN
          IF switch = '0' THEN
             count <= "000";
          ELSIF rising_edge(clk) THEN
                IF count /= "111" THEN
                   count <= count + 1;
                END IF;
          END IF;
          IF count = "111" AND switch = '1' THEN
             switch_state <= '1';
          ELSE
              switch_state <= '0';
          END IF;
     END PROCESS;
END debounced_switch;
