----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:08:41 10/11/2010 
-- Design Name: 
-- Module Name:    register - Behavioral 
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
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg8 is

port(I      : in  std_logic_vector(7 downto 0);
     clock  : in  std_logic;
     enable : in  std_logic;
     Q      : out std_logic_vector(7 downto 0)
    );
end reg8;

architecture behv of reg8 is
begin

  process(I, clock, enable)
  begin

    if rising_edge(clock) then
      if enable = '1' then
        Q <= I;
      end if;
    end if;

  end process;

end behv;

--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg16 is

port(I      : in  std_logic_vector(15 downto 0);
     clock  : in  std_logic;
     enable : in  std_logic;
     Q      : out std_logic_vector(15 downto 0)
    );
end reg16;

architecture behv of reg16 is
begin

  process(I, clock, enable)
  begin

    if rising_edge(clock) then
      if enable = '1' then
        Q <= I;
      end if;
    end if;

  end process;

end behv;
