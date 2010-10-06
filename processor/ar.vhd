----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:  18:59:20 09/18/2010
-- Design Name: 
-- Module Name:  ar - Behavioral
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
--use ieee.std_logic_unsigned.all;


library work;
--use work.cpu.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ar is
  Port (clk      : in   STD_LOGIC;
        enable   : in   STD_LOGIC;
        read     : in   STD_LOGIC;                       -- (not write)
        SelR     : in   STD_LOGIC_VECTOR (1 downto 0);   -- Select the address register
        Ri       : in   STD_LOGIC_VECTOR (15 downto 0);  -- The Rx output
        Ro       : out  STD_LOGIC_VECTOR (15 downto 0)); -- The Ry output
end ar;


architecture Behavioral of ar is
BEGIN
  process()
  BEGIN

  end process;
end Behavioral;
