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

ENTITY switch_reg IS
PORT( D : IN STD_LOGIC;
      reset, clk : IN STD_LOGIC;
      Q : OUT STD_LOGIC);

ARCHITECTURE reg_arch OF switch_reg IS
BEGIN
     PROCESS(D, reset, clk)
            IF reset = '1' THEN
               Q <= (OTHERS => '0');
            ELSIF rising_edge(clk) THEN
                  Q <= D;
            END IF;
     END PROCESS;
END reg_arch;
