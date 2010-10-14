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
  
    FA0: fulladder PORT MAP(A(0), B(0), Carry(0), Sum(0), Carry(1));
    FA1: fulladder PORT MAP(A(1), B(1), Carry(1), Sum(1), Carry(2));
    FA2: fulladder PORT MAP(A(2), B(2), Carry(2), Sum(2), Carry(3));
    FA3: fulladder PORT MAP(A(3), B(3), Carry(3), Sum(3), Carry(4));
    FA4: fulladder PORT MAP(A(4), B(4), Carry(4), Sum(4), Carry(5));
    FA5: fulladder PORT MAP(A(5), B(5), Carry(5), Sum(5), Carry(6));
    FA6: fulladder PORT MAP(A(6), B(6), Carry(6), Sum(6), Carry(7));
    FA7: fulladder PORT MAP(A(7), B(7), Carry(7), Sum(7), Carry(8));
  
  Cout <= Carry(8);
end arch_fulladder8;

-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fulladder16 is
  Port (A    : in   STD_LOGIC_VECTOR( 15 downto 0);
        B    : in   STD_LOGIC_VECTOR( 15 downto 0);
        Cin  : in   STD_LOGIC;
        Sum  : out  STD_LOGIC_VECTOR( 15 downto 0);
        Cout : out  STD_LOGIC
        );
end fulladder16;

architecture arch_fulladder16 of fulladder16 is
  component fulladder IS
  Port (Ax   : in   STD_LOGIC;
        Bx   : in   STD_LOGIC;
        Ci   : in   STD_LOGIC;
        Sx   : out  STD_LOGIC;
        Co   : out  STD_LOGIC
        );
  end component;
  signal Carry   : std_logic_vector(16 downto 0);
BEGIN
  Carry(0) <= Cin;
  
    FA0:  fulladder PORT MAP(A(0), B(0), Carry(0), Sum(0), Carry(1));
    FA1:  fulladder PORT MAP(A(1), B(1), Carry(1), Sum(1), Carry(2));
    FA2:  fulladder PORT MAP(A(2), B(2), Carry(2), Sum(2), Carry(3));
    FA3:  fulladder PORT MAP(A(3), B(3), Carry(3), Sum(3), Carry(4));
    FA4:  fulladder PORT MAP(A(4), B(4), Carry(4), Sum(4), Carry(5));
    FA5:  fulladder PORT MAP(A(5), B(5), Carry(5), Sum(5), Carry(6));
    FA6:  fulladder PORT MAP(A(6), B(6), Carry(6), Sum(6), Carry(7));
    FA7:  fulladder PORT MAP(A(7), B(7), Carry(7), Sum(7), Carry(8));
    FA8:  fulladder PORT MAP(A(8), B(8), Carry(8), Sum(8), Carry(9));
    FA9:  fulladder PORT MAP(A(9), B(9), Carry(9), Sum(9), Carry(10));
    FA10: fulladder PORT MAP(A(10), B(10), Carry(10), Sum(10), Carry(11));
    FA11: fulladder PORT MAP(A(11), B(11), Carry(11), Sum(11), Carry(12));
    FA12: fulladder PORT MAP(A(12), B(12), Carry(12), Sum(12), Carry(13));
    FA13: fulladder PORT MAP(A(13), B(13), Carry(13), Sum(13), Carry(14));
    FA14: fulladder PORT MAP(A(14), B(14), Carry(14), Sum(14), Carry(15));
    FA15: fulladder PORT MAP(A(15), B(15), Carry(15), Sum(15), Carry(16));
  
  Cout <= Carry(16);
end arch_fulladder16;
