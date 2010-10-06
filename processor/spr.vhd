----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:  18:59:20 09/18/2010
-- Design Name: 
-- Module Name:  spr - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: The Special Purpose Register is 3, 16bit registers. One for the PC,
-- another for the SR and the third is the IR.
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

entity spr is
  Port (clk      : in   STD_LOGIC;
        enable   : in   STD_LOGIC;
        read     : in   STD_LOGIC;                       -- (not write)
        SelR     : in   STD_LOGIC_VECTOR (1 downto 0);   -- PC(0) SR(1) IR(2)
        Ri       : in   STD_LOGIC_VECTOR (15 downto 0);  -- The input to the SPR
        Ro       : out  STD_LOGIC_VECTOR (15 downto 0)); -- The output from SPR
end spr;


architecture Behavioral of spr is
  signal  Rpc    : std_logic_vector(15 downto 0);
  signal  Rsr    : std_logic_vector(15 downto 0);
  signal  Rir    : std_logic_vector(15 downto 0);
BEGIN
  process(clk, enable, SelR, Ri)
  BEGIN
    IF (rising_edge(clk)) THEN
      IF (enable = '1') THEN
        IF (read = '1') THEN
          CASE SelR IS
            when "00" =>
              Ro <= Rpc;
            when "01" =>
              Ro <= Rsr;
            when "10" =>
              Ro <= Rir;
            when others =>
              Ro <= (others => '0');
          END CASE;
        ELSE -- not read (write)
          CASE SelR IS
            when "00" =>
              Rpc <= Ri;
            when "01" =>
              Rsr <= Ri;
            when "10" =>
              Rir <= Ri;
            when others =>
              NULL;
          END CASE;
        END IF;
      END IF;
    END IF;
  end process;
end Behavioral;

