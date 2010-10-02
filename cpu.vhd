----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:09:46 09/15/2010 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.buses.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is

  PORT(
    clk            : IN std_logic;
    Rinsel         : IN std_logic_vector(2 DOWNTO 0); -- Which register to write
    Routsel        : IN std_logic_vector(2 DOWNTO 0); -- Which register to read
    read, write    : IN std_logic; -- Flags for read or write control
    Rin            : IN std_logic_vector(7 DOWNTO 0); -- Input signals
    Rout           : OUT std_logic_vector(7 DOWNTO 0)); -- Output signals

end cpu;

architecture Behavioral of cpu is

SIGNAL reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7 : std_logic_vector(7 DOWNTO 0);

begin

  -- WRITE PROCESS: To write to the registers
  PROCESS (clk, write, Rinsel)
  BEGIN
    IF clk 'EVENT AND clk= '1' THEN
      IF write = '1' THEN
        CASE Rinsel IS
          WHEN "000" => reg0 <= Rin;
          WHEN "001" => reg1 <= Rin;
          WHEN "010" => reg2 <= Rin;
          WHEN "011" => reg3 <= Rin;
          WHEN "100" => reg4 <= Rin;
          WHEN "101" => reg5 <= Rin;
          WHEN "110" => reg6 <= Rin;
          WHEN "111" => reg7 <= Rin;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS;

  -- READ PROCESS: To read from the registers
  PROCESS (read, Routsel)
  BEGIN
    IF read = '1' THEN
      CASE Routsel IS
        WHEN "000" => Rout <= reg0;
        WHEN "001" => Rout <= reg1;
        WHEN "010" => Rout <= reg2;
        WHEN "011" => Rout <= reg3;
        WHEN "100" => Rout <= reg4;
        WHEN "101" => Rout <= reg5;
        WHEN "110" => Rout <= reg6;
        WHEN "111" => Rout <= reg7;
        WHEN OTHERS => NULL;
      END CASE;
    END IF;
  END PROCESS;

end Behavioral;
