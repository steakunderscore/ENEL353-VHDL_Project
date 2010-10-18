----------------------------------------------------------------------------------
-- Module Name:    switch_reg
-- Description: Entity to store switch state (can be extended to more than one)
-- Authors: Tracy Jackson
--          Sasha Wang
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;

ENTITY switch_reg IS
PORT( D                 : IN STD_LOGIC;
      clk,enable    : IN STD_LOGIC;
      Q                 : OUT STD_LOGIC);
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
