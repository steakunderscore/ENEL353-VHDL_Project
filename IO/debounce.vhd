----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    16:08:33 09/15/2010
-- Design Name:
-- Module Name:    IO - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;

ENTITY debounce IS
       PORT(clk : IN STD_LOGIC;
       switch : IN STD_LOGIC;
       switch_state : OUT STD_LOGIC);
END debounce;

ARCHITECTURE debounced_switch OF debounce IS
             SIGNAL count : STD_LOGIC_VECTOR(1 DOWNTO 0);  --variable or signal???
BEGIN
     PROCESS(clk)
     BEGIN
          IF switch = '0' THEN
             count <= "000";
          ELSIF rising_edge(clk) THEN
                IF count /= "111" THEN
                   count <= count + 1;
                END IF;
          END IF;
          IF count = "111" AND switch = '1' THEN
             switch_state = '1';
          ELSE
              switch_state = '0';
          END IF;
     END PROCESS;
END debounced_switch;
