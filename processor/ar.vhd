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
        Ri       : in   STD_LOGIC_VECTOR (15 downto 0);  -- The input
        Ro       : out  STD_LOGIC_VECTOR (15 downto 0)); -- The output
end ar;


architecture Behavioral of ar is
  signal  A0     : std_logic_vector(15 downto 0);
  signal  A1     : std_logic_vector(15 downto 0);
  signal  A2     : std_logic_vector(15 downto 0);
BEGIN
  process(clk, enable, SelR, Ri)
  BEGIN
    IF (rising_edge(clk)) THEN
      IF (enable = '1') THEN
        IF (read = '1') THEN
          CASE SelR IS
            when "00" =>
              Ro <= A0;
            when "01" =>
              Ro <= A1;
            when "10" =>
              Ro <= A2;
            when others =>
              Ro <= (others => '0');
          END CASE;
        ELSE -- not read (write)
          CASE SelR IS
            when "00" =>
              A0 <= Ri;
            when "01" =>
              A1 <= Ri;
            when "10" =>
              A2 <= Ri;
            when others =>
              NULL;
          END CASE;
        END IF;
      END IF;
    END IF;
  end process;
end Behavioral;

