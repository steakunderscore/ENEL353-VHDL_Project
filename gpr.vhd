----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:  18:59:20 09/18/2010 
-- Design Name: 
-- Module Name:  GPR - Behavioral 
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

entity gpr is
  Port (clk      : in   STD_LOGIC;
        enable   : in   STD_LOGIC;
        SelRx    : in   STD_LOGIC_VECTOR (2 downto 0);  -- The Rx output selection value
        SelRy    : in   STD_LOGIC_VECTOR (2 downto 0);  -- The Ry output selection value
        SelRi    : in   STD_LOGIC_VECTOR (2 downto 0);  -- The Ri input selection value
        Ri       : in   STD_LOGIC_VECTOR (7 downto 0);  -- The Ri input to GPR
        Rx       : out  STD_LOGIC_VECTOR (7 downto 0);  -- The Rx output
        Ry       : out  STD_LOGIC_VECTOR (7 downto 0)); -- The Ry output
end gpr;


architecture Behavioral of gpr is
  signal  R0  : std_logic_vector(7 downto 0);
  signal  R1  : std_logic_vector(7 downto 0);
  signal  R2  : std_logic_vector(7 downto 0);
  signal  R3  : std_logic_vector(7 downto 0);
  signal  R4  : std_logic_vector(7 downto 0);
  signal  R5  : std_logic_vector(7 downto 0);
  signal  R6  : std_logic_vector(7 downto 0);
  signal  R7  : std_logic_vector(7 downto 0);
BEGIN
  process(clk, SelRx, SelRy)
  BEGIN
    IF (rising_edge(clk)) THEN
      CASE SelRx IS
        when "000" =>
          Rx <= R0;
        when "001" =>
          Rx <= R1;
        when "010" =>
          Rx <= R2;
        when "011" =>
          Rx <= R3;
        when "100" =>
          Rx <= R4;
        when "101" =>
          Rx <= R5;
        when "110" =>
          Rx <= R6;
        when "111" =>
          Rx <= R7;
        when others =>
          Rx <= (others => '0');
      END CASE;
      CASE SelRy IS
        when "000" =>
          Ry <= R0;
        when "001" =>
          Ry <= R1;
        when "010" =>
          Ry <= R2;
        when "011" =>
          Ry <= R3;
        when "100" =>
          Ry <= R4;
        when "101" =>
          Ry <= R5;
        when "110" =>
          Ry <= R6;
        when "111" =>
          Ry <= R7;
        when others =>
          Ry <= (others => '0');
      END CASE;
    END IF;
  end process;

  process(clk, SelRi)
  BEGIN
    IF (rising_edge(clk)) THEN
      CASE SelRi IS
        when "000" =>
          R0 <= Ri;
        when "001" =>
          R1 <= Ri;
        when "010" =>
          R2 <= Ri;
        when "011" =>
          R3 <= Ri;
        when "100" =>
          R4 <= Ri;
        when "101" =>
          R5 <= Ri;
        when "110" =>
          R6 <= Ri;
        when "111" =>
          R7 <= Ri;
        when others =>
          NULL;
      END CASE;
    END IF;
  end process;
end Behavioral;

