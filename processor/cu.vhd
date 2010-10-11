----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:  18:59:20 09/18/2010 
-- Design Name: 
-- Module Name:  cu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: The control unit
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
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;


library work;
use WORK.NUMERIC_STD.ALL;
--use work.cpu.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cu is
  Port (opcode : in  STD_LOGIC_VECTOR (15 downto 0); -- the instruction opcode
        alu_f  : out STD_LOGIC_VECTOR (3 downto 0);
  --TODO: complete the control unit
        );
end cu;


architecture Behavioral of cu is
BEGIN

end Behavioral;

