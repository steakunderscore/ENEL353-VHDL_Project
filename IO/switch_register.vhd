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
-- Revision: Saturday, 16 Oct 2010 by Sasha 
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
PORT( D 				: IN STD_LOGIC;
      clk,enable	: IN STD_LOGIC;
      Q 				: OUT STD_LOGIC);
END switch_reg;

ARCHITECTURE reg_arch OF switch_reg IS
BEGIN
     PROCESS(D, enable, clk)
	  BEGIN
            IF rising_edge(clk) THEN --Need else there???
					IF enable = '1' THEN 
						Q <= D;
					END IF;
            END IF;
     END PROCESS;
END reg_arch;
