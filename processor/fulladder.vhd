----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:  18:59:20 09/18/2010 
-- Design Name: 
-- Module Name:  fulladder - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fulladder is
  Port (A    : in   STD_LOGIC;
        B    : in   STD_LOGIC;
        Cin  : in   STD_LOGIC;
        Sum  : out  STD_LOGIC;
        Cout : out  STD_LOGIC
        );
end fulladder;


architecture Behavioral of fulladder is
BEGIN
  process(A, B, Cin)
    variable AxorB : std_logic; -- Make the code easier to read
  BEGIN
    AxorB := (A XOR B);
    Sum <= AxorB XOR Cin;
    Cout <= (AxorB XOR Cin) OR (A AND B);
  end process;
end Behavioral;

