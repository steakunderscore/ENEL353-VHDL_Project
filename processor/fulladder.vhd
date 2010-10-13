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

entity fulladder is
  Port (Ax   : in   STD_LOGIC;
        Bx   : in   STD_LOGIC;
        Ci   : in   STD_LOGIC;
        Sx   : out  STD_LOGIC;
        Co   : out  STD_LOGIC
        );
end fulladder;


architecture arch_fulladder of fulladder is
BEGIN
  process(Ax, Bx, Ci)
  BEGIN
    Sx <= (Ax XOR Bx) XOR Ci;
    Co <= (Ax and Bx) or (Ax and Ci) OR (Bx AND Ci);
  end process;
end arch_fulladder;

-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fulladder8 is
  Port (A    : in   STD_LOGIC_VECTOR( 7 downto 0);
        B    : in   STD_LOGIC_VECTOR( 7 downto 0);
        Cin  : in   STD_LOGIC;
        Sum  : out  STD_LOGIC_VECTOR( 7 downto 0);
        Cout : out  STD_LOGIC
        );
end fulladder8;

architecture arch_fulladder8 of fulladder8 is
  component fulladder IS
  Port (Ax   : in   STD_LOGIC;
        Bx   : in   STD_LOGIC;
        Ci   : in   STD_LOGIC;
        Sx   : out  STD_LOGIC;
        Co   : out  STD_LOGIC
        );
  end component;
  signal Carry   : std_logic_vector(8 downto 0);
BEGIN
  Carry(0) <= Cin;
  
  --Adder8:
  --FOR i IN 0 to 7 GENERATE
    FA0: fulladder PORT MAP(A(0), B(0), Carry(0), Sum(0), Carry(1));
    FA1: fulladder PORT MAP(A(1), B(1), Carry(1), Sum(1), Carry(2));
    FA2: fulladder PORT MAP(A(2), B(2), Carry(2), Sum(2), Carry(3));
    FA3: fulladder PORT MAP(A(3), B(3), Carry(3), Sum(3), Carry(4));
    FA4: fulladder PORT MAP(A(4), B(4), Carry(4), Sum(4), Carry(5));
    FA5: fulladder PORT MAP(A(5), B(5), Carry(5), Sum(5), Carry(6));
    FA6: fulladder PORT MAP(A(6), B(6), Carry(6), Sum(6), Carry(7));
    FA7: fulladder PORT MAP(A(7), B(7), Carry(7), Sum(7), Carry(8));
    --FAx: fulladder PORT MAP(Ax => A(i), Bx => B(i), Cin => Carry(i), Sx => Sum(i), Cout => Carry(i+1));
  --END GENERATE;
  
  Cout <= Carry(8);
end arch_fulladder8;
