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

  PORT( --TODO: Change these to the actual port map
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
  END PROCESS;

end Behavioral;
